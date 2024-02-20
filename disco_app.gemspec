$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'disco_app/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'disco_app'
  s.version     = DiscoApp::VERSION
  s.authors     = ['Gavin Ballard']
  s.email       = ['gavin@gavinballard.com']
  s.homepage    = 'https://github.com/discolabs/disco_app/'
  s.summary     = 'Rails engine for Shopify applications.'
  s.description = 'Rails engine for Shopify applications.'
  s.license     = 'MIT'

  # To build up the list of files, we need to deviate from the standard .gemspec approach to ensure that
  # a number of "dotfiles"/"dotfolders" that we use as templates files are included in our gem package.
  s.files = Dir.glob('{app,config,db,lib}/**/{*,.*}', File::FNM_DOTMATCH).reject { |d| d.end_with?('.') }
  s.files += Dir['MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.test_files = Dir['test/**/*']

  s.add_runtime_dependency 'active_link_to', '~> 1.0'
  s.add_runtime_dependency 'active_utils', '~> 3.2'
  s.add_runtime_dependency 'activemodel-serializers-xml', '~> 1.0'
  s.add_runtime_dependency 'activerecord-session_store', '~> 1.0'
  s.add_runtime_dependency 'acts_as_singleton', '~> 0.0.8'
  s.add_runtime_dependency 'appsignal', '~> 2.9'
  s.add_runtime_dependency 'classnames-rails', '~> 2.1'
  s.add_runtime_dependency 'coffee-rails', '~> 4.2'
  s.add_runtime_dependency 'interactor'
  s.add_runtime_dependency 'jquery-rails', '~> 4.3'
  s.add_runtime_dependency 'jsonapi-resources', '~> 0.9'
  s.add_runtime_dependency 'mailgun_rails', '~> 0.8'
  s.add_runtime_dependency 'nokogiri', '~> 1.7'
  s.add_runtime_dependency 'pg', '~> 1.1'
  s.add_runtime_dependency 'premailer-rails', '~> 1.8'
  s.add_runtime_dependency 'puma', '>= 3.9'
  s.add_runtime_dependency 'rails', '~> 6.0'
  s.add_runtime_dependency 'rails_12factor', '~> 0.0.3'
  s.add_runtime_dependency 'react-rails', '~> 2.5'
  s.add_runtime_dependency 'sass-rails', '~> 6.0'
  s.add_runtime_dependency 'shopify_api', '~> 13.4.0'
  s.add_runtime_dependency 'shopify_app', '~> 21.3'
  s.add_runtime_dependency 'sidekiq', '~> 6.0'
  s.add_runtime_dependency 'sinatra', '~> 2.0'
  s.add_runtime_dependency 'turbolinks', '~> 5.2'
  s.add_runtime_dependency 'uglifier', '~> 4.1'

  s.add_development_dependency 'dotenv-rails', '~> 2.0'
  s.add_development_dependency 'minitest', '5.11.3'
  s.add_development_dependency 'minitest-reporters', '1.3'
  s.add_development_dependency 'minitest-stub-const'
  s.add_development_dependency 'rubocop', '~> 0.77'
  s.add_development_dependency 'rubocop-performance', '~> 1.5.1'
  s.add_development_dependency 'rubocop-rails', '~> 2.4.0'
  s.add_development_dependency 'vcr', '~> 5.0'
  s.add_development_dependency 'webmock', '~> 3.6'
end
