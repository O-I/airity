module Airity
  class Runner
    include Capybara::DSL

    def create
      # Default browser is Firefox
      Capybara.default_driver = :selenium
      Capybara.app_host = 'https://plus.google.com'

      # Use ~/.airity configuration file
      configure

      # Collect credentials from command line
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
      rescue => e
        # User is already logged in
      end

      # Allow for 2FA, if required
      begin
        authentication_token = ask('Token:') { |q| q.echo = false }
        fill_in 'Enter code', with: authentication_token
        click_button 'Verify'
      rescue => e
        # 2FA is not required
      end

      # Navigate to Google+ Hangouts on Air page
      visit '/hangouts/onair'

      find('div[role="button"]', text: 'Start a Hangout On Air').click

      meeting_name = #@config[:meeting_name] ||
                     ask('Meeting name:') { |q| q.echo = true }
      fill_in 'Give it a name', with: meeting_name

      # Clear Audience text field
      find('div[title="Browse people"]').click
      find('span', text: 'selected', exact: false).click
      find('div[role="button"]', text: 'Unselect all').click

      # prompt for email addresses of speakers and admin(s), e.g.,
      puts 'Enter the email addresses of this month\'s speakers ' \
           'separated by spaces (don\'t forget to invite yourself!)'
      invitees = ask('Invitees:') { |q| q.echo = true }

      find('input[aria-label="Search terms"]').set(invitees)

      find('div[role="button"]', text: 'Select all').click
      find('div[role="button"]', text: 'Done').click

      # Remove Public from Audience...again
      begin
        find('div[aria-label="Remove Public"]').click
      rescue => e
        # Public wasn't re-added
      end

      find('div[role="button"]', text: 'Share').click

      # Make it full screen
      `osascript -e 'tell application "System Events" to keystroke "f" using {command down, control down}'`

      # Wait for some input so script doesn't exit
      puts 'Press `return` to quit'
      STDIN.gets
    end
  end
end