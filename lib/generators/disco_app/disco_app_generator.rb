class DiscoAppGenerator < Rails::Generators::Base

  source_root File.expand_path('../templates', __FILE__)

  # Copy a number of template files to the top-level directory of our application:
  #
  #  - .env and .env.sample for settings environment variables in development with dotenv-rails;
  #  - Slightly customised version of the default Rails .gitignore;
  #  - Default simple Procfile for Heroku.
  #
  def copy_root_files
    %w(.env .env.sample .gitignore Procfile).each do |file|
      copy_file "root/#{file}", file
    end
  end

  # Remove a number of root files.
  def remove_root_files
    %w(README.rdoc).each do |file|
      remove_file file
    end
  end

  # Configure the application's Gemfile.
  def configure_gems
    # Remove sqlite from the general Gemfile.
    gsub_file 'Gemfile', /^# Use sqlite3 as the database for Active Record\ngem 'sqlite3'/m, ''

    # Add gems common to all environments.
    gem 'shopify_app', '~> 6.1.0'
    gem 'sidekiq', '~> 3.3.4'
    gem 'puma', '~> 2.11.3'

    # Add gems for development and testing only.
    gem_group :development, :test do
      gem 'sqlite3', '~> 1.3.10'
      gem 'dotenv-rails', '~> 2.0.2'
    end

    # Add gems for production only.
    gem_group :production do
      gem 'pg', '~> 0.18.2'
      gem 'rails_12factor', '~> 0.0.3'
    end
  end

  # Make any required adjustments to the application configuration.
  def configure_application
    # The force_ssl flag is commented by default for production.
    # Uncomment to ensure config.force_ssl = true in production.
    uncomment_lines 'config/environments/production.rb', /force_ssl/

    # Ensure the application configuration uses the DEFAULT_HOST environment variable to set up support for reverse
    # routing absolute URLS (needed when generating Webhook URLs for example).
    application "routes.default_url_options[:host] = ENV['DEFAULT_HOST']"
    application "# Set the default host for absolute URL routing purposes"

    # Set Sidekiq as the queue adapter in production.
    application "config.active_job.queue_adapter = :sidekiq", env: :production
    application "# Use Sidekiq as the active job backend", env: :production

    # Copy over the default puma configuration.
    copy_file 'config/puma.rb', 'config/puma.rb'
  end

  # Create Rakefiles
  def create_rakefiles
    rakefile 'start.rake' do
      %Q{
        task start: :environment do
          system 'bundle exec rails server -b 127.0.0.1 -p 3000'
        end
      }
    end
  end

  # Run shopify_app:install and shopify_app:shop_model
  def shopify_app_install
    generate 'shopify_app:install'
    generate 'shopify_app:shop_model'
  end

  # Set up initializers, overriding some of the defaults generated by shopify_app:install and shopify_app:shop_model
  def setup_initializers
    copy_file 'initializers/shopify_app.rb', 'config/initializers/shopify_app.rb'
    copy_file 'initializers/disco_app.rb', 'config/initializers/disco_app.rb'
  end

  # Set up models, overriding some of the defaults generated by shopify_app:install and shopify_app:shop_model
  def setup_models
    copy_file 'models/shop.rb', 'app/models/shop.rb'
    # @TODO: Copy migrations.
  end

  # Set up default jobs.
  def setup_jobs
    ['app_installed', 'app_uninstalled', 'shop_update'].each do |job_name|
      copy_file "jobs/#{job_name}_job.rb", "app/jobs/#{job_name}_job.rb"
    end
  end

  # Set up routes.
  def setup_routes
    route "mount DiscoApp::Engine, at: '/'"
  end

  # Copy engine migrations over.
  def install_migrations
    rake 'disco_app:install:migrations'
  end

  # Run migrations.
  def migrate
    rake 'db:migrate'
  end

  # Lock down the application to a specific Ruby version:
  #
  #  - Via .ruby-version file for rbenv in development;
  #  - Via a Gemfile line in production.
  #
  # This should be the last operation, to allow all other operations to run in the initial Ruby version.
  def set_ruby_version
    copy_file 'root/.ruby-version', '.ruby-version'
    prepend_to_file 'Gemfile', "ruby '2.2.2'\n"
  end

end
