# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
ENV['BASE_URL'] = 'http://127.0.0.1:3055' # CircleCI ignores config/application.yml 'test' key/values

require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|

  # wipes db between tests, reduces validation error false negatives
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.around(:each, :run_delayed_jobs) do |example|
    Delayed::Worker.delay_jobs = false
    example.run
    Delayed::Worker.delay_jobs = true
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  Capybara.register_driver :chrome do |app|
    # profile = Selenium::WebDriver::Chrome::Profile.new
    # profile["intl.accept_languages"] = "de"

    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(loggingPrefs: { browser: 'ALL' })

    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--lang=de')
    #options.add_argument('--incognito')

    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      #profile: profile
      options: options,
      capabilities: [capabilities]
    )
  end

  default_driver = :chrome
  default_driver = :selenium_chrome_headless if ENV['CIRCLE_ARTIFACTS']
  Capybara.javascript_driver = (ENV['CAPYBARA_JS_DRIVER'] || default_driver).to_sym

  Capybara.server_port = 3055

  def save_timestamped_screenshot(page, meta)
    filename = File.basename(meta[:file_path])
    line_number = meta[:line_number]

    time_now = Time.now
    timestamp = "#{time_now.strftime('%Y-%m-%d-%H-%M-%S.')}#{'%03d' % (time_now.usec/1000).to_i}"

    screenshot_name = "screenshot-#{filename}-#{line_number}-#{timestamp}.png"
    screenshot_path = "#{ENV.fetch('CIRCLE_ARTIFACTS', Rails.root.join('tmp/capybara'))}/#{screenshot_name}"

    page.save_screenshot(screenshot_path)
    puts "\n  Screenshot: #{screenshot_path}"
  end

  config.after(:each) do |example|
    if example.metadata[:js]
      save_timestamped_screenshot(Capybara.page, example.metadata) if example.exception
    end
  end

  # config.after(:each, type: :system, js: true) do
  #   errors = page.driver.browser.manage.logs.get(:browser)
  #   if errors.present?
  #     aggregate_failures 'javascript errrors' do
  #       errors.each do |error|
  #         expect(error.level).not_to eq('SEVERE'), error.message
  #         next unless error.level == 'WARNING'
  #         STDERR.puts 'WARN: javascript warning'
  #         STDERR.puts error.message
  #       end
  #     end
  #   end
  # end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec

    # Or, choose the following (which implies all of the above):
    with.library :rails
  end
end
