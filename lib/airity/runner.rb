require 'erb'
require 'yaml'

module Airity
  class Runner
    include Capybara::DSL

    def create
      # Default browser is Firefox
      Capybara.default_driver = :selenium
      Capybara.app_host = 'https://plus.google.com'
      Capybara.default_wait_time = 5

      configure                 # Use ~/.airity configuration file
      visit '/'                 # Navigate to Google+ log in page
      log_in                    # Log in, if needed
      two_factor_authenticate   # Allow for 2FA, if required
      visit '/hangouts/onair'   # Navigate to Google+ Hangouts on Air page
      create_hangout            # Begin filling in Hangout on Air form
      send_invitations          # Invite this month's speakers
      share_hangout             # Share the Hangout privately
      publicize youtube_link    # Share the public YouTube link
      make_it_full_screen       # Make it full screen

      # Wait for some input so script doesn't exit
      puts 'Press `return` to quit'
      STDIN.gets
    end

    private

    def configure
      begin
        @config = YAML.load(ERB.new(File.read("#{Dir.home}/.airity")).result)
      rescue => e
        # File doesn't exist
        @config ||= {}
        puts "You can add a #{Dir.home}/.airity file " \
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
      prompt = 'Enter the email addresses of this month\'s speakers ' \
               'separated by spaces (don\'t forget to invite yourself!)'
      @config[:invitees] * ' ' || ask(prompt) { |q| q.echo = true }
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

    def create_hangout
      find('div[role="button"]', text: 'Create a Hangout On Air').click
      fill_in 'Give it a name', with: meeting_name
      clear_audience_text_field
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
      ensure_private_hangout
      find('div[role="button"]', text: 'Share').click
    end

    def youtube_link
      begin
        sleep 5
        execute_script("document.getElementsByClassName('Wfb')[0].click();")
        evaluate_script("document.getElementsByTagName('input')[5].value;")
      rescue Selenium::WebDriver::Error::JavascriptError
        retry
      end
    end

    def publicize(link)
      message = "The public YouTube link is #{link}"
      puts message
      find('div[role="button"]', text: 'Share event').click
    end

    def make_it_full_screen
      `osascript -e 'tell application "System Events" to keystroke "f" using {command down, control down}'`
    end
  end
end