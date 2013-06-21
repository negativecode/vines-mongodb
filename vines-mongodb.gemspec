Gem::Specification.new do |s|
  s.name         = 'vines-mongodb'
  s.version      = '0.1.0'
  s.summary      = %q[Provides a MongoDB storage adapter for the Vines XMPP chat server.]
  s.description  = %q[Stores Vines user data in MongoDB.]

  s.authors      = ['David Graham']
  s.email        = %w[david@negativecode.com]
  s.homepage     = 'http://www.getvines.org'
  s.license      = 'MIT'

  s.files        = Dir['[A-Z]*', 'vines-mongodb.gemspec', 'lib/**/*'] - ['Gemfile.lock']
  s.test_files   = Dir['spec/**/*']
  s.require_path = 'lib'

  s.add_dependency 'mongo', '~> 1.5.2'
  s.add_dependency 'bson_ext', '~> 1.5.2'
  s.add_dependency 'vines', '>= 0.4.5'

  s.add_development_dependency 'minitest', '~> 4.7.4'
  s.add_development_dependency 'rake', '~> 10.1.0'

  s.required_ruby_version = '>= 1.9.3'
end
