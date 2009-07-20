spec = Gem::Specification.new do |s| 
  s.name = "jabber_cat"
  s.version = "0.0.7"
  s.author = "Rob Partington"
  s.email = "zimpenfish@gmail.com"
  s.homepage = "http://rjp.github.com/jabber_cat"
  s.platform = Gem::Platform::RUBY
  s.summary = "Simple Socket-to-Jabber gateway"
  s.files = ['bin/jabber_cat.rb', 'lib/jabber_cat/options.rb']
  s.require_path = "lib"
  s.test_files = []
  s.add_dependency('xmpp4r', '>= 0.4')
  s.executables = ['jabber_cat.rb']
  s.has_rdoc = true
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.rubyforge_project = nil
end

