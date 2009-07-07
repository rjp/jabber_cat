require 'rubygems'
require 'optparse'
require 'socket'
require 'xmpp4r'
require 'xmpp4r/framework/bot'
include Jabber

$options = {
    :host => 'localhost',
    :port => 9999,
    :whoto => nil,
    :config => ENV['HOME'] + '/.jabber_cat'
}

OptionParser.new do |opts|
  opts.banner = "Usage: twittermoo.rb [-p port] [-h host] [-w jid]"

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
end.parse!

if $options[:whoto].nil? then
    $options[:debug] = true
end

# TODO handle failing here with exceptions
config = YAML::load(open($options[:config]))

# make sure we always have a filters list
if config['filters'].nil? then
    config['filters'] = []
end

if $options[:debug] then
    puts "listening to socket on #{$options[:host]}:#{$options[:port]}"
end
server = TCPServer.new($options[:host], $options[:port])

x = Thread.new do 
    loop do
        ignore = nil
        s = server.accept
	  	line = s.gets.chomp.gsub(/\r/,'')

        config['filters'].each { |f|
            if line =~ /#{f}/ then
                ignore = true
            end
        }

        if ignore.nil? then
	        if $options[:debug] then
			    puts "got line [#{line}]"
			    puts "sending it to #{$options[:whoto]}"
	        end
	        if $options[:debug] then
	            puts "<#{$options[:whoto]}> #{line}"
	        else
                $bot.send_message($options[:whoto], line)
	        end
        end
        s.close
    end
end

if $options[:debug] then
    puts "creating jabber connection now"
end

Jabber::debug = true

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

x.join
