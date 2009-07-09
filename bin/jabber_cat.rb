require 'rubygems'
require 'optparse'
require 'socket'
require 'xmpp4r'
require 'xmpp4r/framework/bot'
include Jabber

def log(x)
    if $options[:verbose] then
        puts(*x)
    end
end

$options = {
    :host => 'localhost',
    :port => 9999,
    :whoto => nil,
    :config => ENV['HOME'] + '/.jabber_cat',
    :verbose => nil,
    :debug => 0
}

OptionParser.new do |opts|
  opts.banner = "Usage: twittermoo.rb [-p port] [-h host] [-w jid] [-v] [-d N]"

  opts.on("-p", "--port N", Integer, "irccat port") do |p|
    $options[:port] = p
  end

  opts.on("-h", "--host HOST", String, "host") do |p|
    $options[:host] = p
  end

  opts.on("-w", "--whoto jid", String, "JID") do |p|
    $options[:whoto] = p
  end

  opts.on("-c", "--config CONFIG", String, "config file") do |p|
    $options[:config] = p
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    $options[:verbose] = v
  end

  opts.on("-d", "--debug N", Integer, "debug level") do |p|
    $options[:debug] = p
  end

end.parse!

if $options[:whoto].nil? then # debug = 1 if not already set
    $options[:debug] = $options[:debug] || 1
end

# TODO handle failing here with exceptions
config = YAML::load(open($options[:config]))

unless config['options'].nil? then
    $options.merge!(config['options'])
end

# make sure we always have a filters list
if config['filters'].nil? then
    config['filters'] = []
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

	    log "R #{line}"

        config['filters'].each { |f|
            if line =~ /#{f}/ then
                if $options[:verbose] then
                    log "F #{f} =~ #{line}"
                end
                ignore = true
            end
        }

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

if $options[:debug] > 0 then
    puts "creating jabber connection now"
end

if $options[:debug] > 1 then
    Jabber::debug = true
end

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

# settings
myJID = JID.new(config['myjid'])
myPassword = config['mypass']

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


x.join
