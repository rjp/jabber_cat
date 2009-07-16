puts "included file"

$options = {
    :host => 'localhost',
    :port => 9999,
    :whoto => nil,
    :config => ENV['HOME'] + '/.jabber_cat',
    :verbose => nil,
    :debug => 0,
    :keyfile => nil,
    :muc => nil
}

OptionParser.new do |opts|
  opts.banner = "Usage: twittermoo.rb [-p port] [-h host] [-w jid] [-v] [-d N] [-m] [-k file]"

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

  opts.on("-k", "--key filename", String, "Shared key file") do |p|
    $options[:keyfile] = p
  end

  opts.on("-m", "--muc", "Treat the destination as a MUC") do |v|
    $options[:muc] = v
  end

end.parse!

if $options[:whoto].nil? then # debug = 1 if not already set
    $options[:debug] = $options[:debug] || 1
end

# TODO handle failing here with exceptions
config = YAML::load(open($options[:config]))

# merge the whole of the config file into the $options hash
config.each { |k,v|
    $options[k.to_sym] = v
}
