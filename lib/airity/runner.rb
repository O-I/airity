module Airity
  class Runner
    include Capybara::DSL

    def create
      # Default browser is Firefox
      Capybara.default_driver = :selenium
      Capybara.app_host = 'https://plus.google.com'

      # Use ~/.airity configuration file
      configure

      # Navigate to Google+ log in page
      visit '/'

      # Log in, if needed
      log_in

      # Allow for 2FA, if required
      two_factor_authenticate

      # Navigate to Google+ Hangouts on Air page
      visit '/hangouts/onair'

      start_hangout

      # Clear Audience text field
      clear_audience_text_field

      # Invite this month's speakers
      send_invitations

      # Remove Public from Audience...again
      ensure_private_hangout

      # Share the Hangout privately
      share_hangout

      # Email the public YouTube link — not working yet
      # find('div', text: 'Links').click

      # Make it full screen
      make_it_full_screen

      # Wait for some input so script doesn't exit
      puts 'Press `return` to quit'
      STDIN.gets
    end

    private

    def configure
      begin
        # this doesn't work yet!
        # how do I require an absolute path?
        require "Users/#{ENV['USER']}/.airity"
      rescue LoadError
        # File doesn't exist
        @config ||= {}
        puts "You can add a Users/#{ENV['USER']}/.airity file " \
             'to preset commonly filled fields. '
        puts 'Refer to the .airity_example file or the documentation ' \
             'for more information.'
      end
    end

    def email
      @config[:email] || ask('Email: ') { |q| q.echo = true }
    end

    def password
      @config[:password] || ask('Password: ') { |q| q.echo = false }
    end

    def authentication_token
      ask('Token: ') { |q| q.echo = false }
    end

    def meeting_name
      @config[:meeting_name] || ask('Meeting name: ') { |q| q.echo = true }
    end

    def invitees
      puts 'Enter the email addresses of this month\'s speakers ' \
           'separated by spaces (don\'t forget to invite yourself!)'
      ask('Invitees:') { |q| q.echo = true }
    end

    def log_in
      begin
        find_field('Email')
        fill_in 'Email', with: email
        fill_in 'Password', with: password
        click_button 'Sign in'
      rescue => e
        # User is already logged in
      end
    end

    def two_factor_authenticate
      begin
        fill_in 'Enter code', with: authentication_token
        click_button 'Verify'
      rescue => e
        # 2FA is not required
      end
    end

    def start_hangout
      find('div[role="button"]', text: 'Start a Hangout On Air').click
      fill_in 'Give it a name', with: meeting_name
    end

    def clear_audience_text_field
      find('div[title="Browse people"]').click
      find('span', text: 'selected', exact: false).click
      find('div[role="button"]', text: 'Unselect all').click
    end

    def send_invitations
      find('input[aria-label="Search terms"]').set(invitees)
      find('div[role="button"]', text: 'Select all').click
      find('div[role="button"]', text: 'Done').click
    end

    def ensure_private_hangout
      begin
        find('div[aria-label="Remove Public"]').click
      rescue => e
        # Public wasn't re-added
      end
    end

    def share_hangout
      find('div[role="button"]', text: 'Share').click
    end

    def make_it_full_screen
      `osascript -e 'tell application "System Events" to keystroke "f" using {command down, control down}'`
    end
  end
end