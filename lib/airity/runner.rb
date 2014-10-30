module Airity
  class Runner
    include Capybara::DSL

    def create
      # Default browser is Firefox
      Capybara.default_driver = :selenium
      Capybara.app_host = 'https://plus.google.com'

      email = ask('Email:') { |q| q.echo = true }
      password = ask('Password:') { |q| q.echo = false }

      # Navigate to Google+ log in page
      visit '/'

      # Log in, if needed
      begin
        find_field('Email')
        fill_in 'Email', with: email
        fill_in 'Password', with: password
        click_button 'Sign in'
      rescue
        # User is already logged in
      end

      # Make it full screen
      `osascript -e 'tell application "System Events" to keystroke "f" using {command down, control down}'`

      # Wait for some input so script doesn't exit
      puts 'Press `return` to quit'
      STDIN.gets
    end
  end
end