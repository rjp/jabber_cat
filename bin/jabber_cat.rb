#! /usr/bin/ruby1.8

require 'rubygems' # should only do this if we require it
require 'optparse'
require 'socket'
require 'json'
require 'xmpp4r'
require 'xmpp4r/framework/bot'
require 'xmpp4r/muc/helper/simplemucclient'
include Jabber

require 'jabber_cat/options'

def log(x)
    if $options[:verbose] then
        puts(*x)
    end
end

if $options[:keyfile] then
    puts "loading secret key from #{$options[:keyfile]}"
    $options[:secret_key] = File.open($options[:keyfile]).read.chomp
end

# make sure we always have a filters list
if $options['filters'].nil? then
    $options['filters'] = []
end

if $options[:debug] > 0 then
    puts "listening to socket on #{$options[:host]}:#{$options[:port]}"
end

server = TCPServer.new($options[:host], $options[:port])

x = Thread.new do
    loop do
        ignore = nil
        s = server.accept
	  	line = s.gets.chomp.gsub(/\r/,'')
        if $options[:verbose] then
            puts "[#{line}] received"
        end

	    log "R #{line}"

        if $options[:secret_key] then
            log "K #{$options[:secret_key]}"
            # check the line matches our secret shared key
            match = "%/#{$options[:secret_key]}/%"
            unless line.gsub!(%r{^#{match} }, '') then
                log "line ignored because secret key doesn't match"
                ignore = true
            end
            log "L #{line}"
        else
            # avoid information leakage due to misconfiguration
            # if a line looks like it starts with a secret key, remove it
            line.gsub!(%r{^%/.*?/% }, '')
        end

        $options['filters'].each { |f|
            if line =~ /#{f}/ then
                if $options[:verbose] then
                    log "F #{f} =~ #{line}"
                end
                ignore = true
            end
        }

        if line =~ /^!!JSON/ then
            payload = JSON.load(line[6..-1])
            line = payload['data']
            log "stripped JSON payload wrapper"
        end

        if ignore.nil? then
            log "sending it to #{$options[:whoto]}"
	        if $options[:debug] > 0 then
	            puts "<#{$options[:whoto]}> #{line}"
	        else
                $bot.send_message($options[:whoto], line)
	        end
        end

        s.close
    end
end

# skip jabber entirely if we have high enough debugging
if $options[:debug] > 3 then
    x.join
    exit
end

#### JABBER

# settings
myJID = JID.new($options[:myjid])
myPassword = $options[:mypass]

log "creating jabber connection now"

if $options[:debug] > 1 then
    Jabber::debug = true
end

if $options[:debug] > 2 then
    x.join
    exit
end

if $options[:muc] then # can't distinguish MUC JID from normal JID
    cl = Jabber::Client.new(Jabber::JID.new(myJID))
    cl.connect
    cl.auth(myPassword)
    m = Jabber::MUC::SimpleMUCClient.new(cl)
    class << m
        def send_message(junk, body)
            say(body)
        end
    end
    m.join($options[:whoto])
    $bot = m
else
	subscription_callback = lambda { |item,pres|
	  name = pres.from
	  if item != nil && item.iname != nil
	    name = "#{item.iname} (#{pres.from})"
	  end
	  case pres.type
	    when :subscribe then puts("Subscription request from #{name}")
	    when :subscribed then puts("Subscribed to #{name}")
	    when :unsubscribe then puts("Unsubscription request from #{name}")
	    when :unsubscribed then puts("Unsubscribed from #{name}")
	    else raise "The Roster Helper is buggy!!! subscription callback with type=#{pres.type}"
	  end
	    $bot.set_presence(nil, "Waiting for socket tickling...")
	}

	$bot = Jabber::Framework::Bot.new(myJID, myPassword)
	class << $bot
	  def accept_subscription_from?(jid)
	    if jid == $options[:whoto] then
	        true
	    else
	        false
	    end
	  end
	end

	$bot.set_presence(nil, "Waiting for socket tickling...")

	$bot.roster.add_update_callback { |olditem,item|
	  if [:from, :none].include?(item.subscription) && item.ask != :subscribe && item.jid == $options[:whoto]
	    if $options[:debug] > 0 then
	        puts("Subscribing to #{item.jid}")
	    end
	    item.subscribe
	  end
	}

	$bot.roster.add_subscription_callback(0, nil, &subscription_callback)

	$bot.roster.groups.each { |group|
	    $bot.roster.find_by_group(group).each { |item|
	        if [:from, :none].include?(item.subscription) && item.ask != :subscribe && item.jid == $options[:whoto] then
	            if $options[:debug] > 0 then
	                puts "subscribing to #{item.jid}"
	            end
	            item.subscribe
	        end
	    }
	}
end

x.join
