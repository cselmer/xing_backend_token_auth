$:.push File.expand_path('lib', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'xing_backend_token_auth'
  s.version     = '0.1.33'
  s.authors     = ['Lynn Hurley', 'Hannah Howard', 'Judson Lester']
  s.email       = ['lynn.dylan.hurley@gmail.com', 'hannah@lrdesign.com', 'judson@lrdesign.com']
  s.homepage    = 'http://github.com/RDesign/xing_backend_token_auth'
  s.summary     = 'Token based authentication for rails. Uses Devise + OmniAuth.'
  s.description = 'For use with client side single page apps such as https://github.com/lynndylanhurley/ng-token-auth.'
  s.license     = 'WTFPL'

  s.files      = Dir['{app,config,db,lib}/**/*', 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'bigdecimal', '~> 1.3.5'
  s.add_dependency 'devise', '~> 3.2'
  s.add_dependency 'rails', '~> 4.1'
  s.add_dependency 'sprockets', '< 4'

  # s.add_development_dependency 'mysql2'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'sqlite3', '~> 1.3'
end
