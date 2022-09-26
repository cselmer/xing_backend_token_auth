source 'https://rubygems.org'

# Declare your gem's dependencies in devise_token_auth.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'

gem 'bigdecimal', '~> 1.3.5'
gem 'rake', '~> 10.0.0'

group :development, :test do
  gem 'attr_encrypted'
  gem 'byebug'
  gem 'faker'
  gem 'figaro', git: 'https://github.com/laserlemon/figaro'
  gem 'fuzz_ball'
  gem 'minitest'
  gem 'minitest-focus'
  gem 'minitest-rails'
  gem 'minitest-reporters'
  gem 'omniauth', '~> 1.0'
  gem 'omniauth-facebook', git: 'https://github.com/mkdynamic/omniauth-facebook.git'
  gem 'omniauth-github', git: 'https://github.com/intridea/omniauth-github.git', tag: 'v1.4.0'
  gem 'omniauth-google-oauth2', git: 'https://github.com/zquestz/omniauth-google-oauth2.git', branch: 'v0.8.2'
  gem 'rack-cors', require: 'rack/cors'
  gem 'thor'
end

# code coverage, metrics
group :test do
  gem 'codeclimate-test-reporter', require: nil
end
