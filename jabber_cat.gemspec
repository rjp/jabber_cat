spec = Gem::Specification.new do |s| 
  s.name = "jabber_cat"
  s.version = "0.0.3"
  s.author = "Rob Partington"
  s.email = "zimpenfish@gmail.com"
  s.homepage = "http://rjp.github.com/jabber_cat"
  s.platform = Gem::Platform::RUBY
  s.summary = "Simple Socket-to-Jabber gateway"
  s.files = ['bin/jabber_cat.rb']
  s.require_path = "lib"
  s.test_files = []
  s.has_rdoc = false
  s.add_dependency('xmpp4r', '>= 0.4')
end

