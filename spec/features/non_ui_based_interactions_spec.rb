require 'spec_helper'

describe 'non-UI based interactions' , requires_net_connect: true do
  around(:each) do |example|
    Mappy.configure {|b|}
    WebMock.allow_net_connect!

    example.run
    WebMock.disable_net_connect!
    Mappy.reset!
  end
  let(:work) { Orcid::Work.new(title: "Test Driven Orcid Integration", work_type: 'test') }
  let(:user) { FactoryGirl.create(:user) }
  let(:orcid_profile_password) { 'password1A' }

  context 'issue a profile request', api_abusive: true do

    # Because either ORCID or Mailinator are blocking some emails.
    let(:random_valid_email_prefix) { (0...24).map { (65 + rand(26)).chr }.join.downcase }
    let(:email) {  "#{random_valid_email_prefix}@mailinator.com" }
    let(:profile_request) {
      FactoryGirl.create(:orcid_profile_request, user: user, primary_email: email, primary_email_confirmation: email)
    }
    let(:profile_request_coordinator) { Orcid::ProfileRequestCoordinator.new(profile_request)}

    before(:each) do
      # Making sure things are properly setup
      expect(profile_request.orcid_profile_id).to be_nil
    end

    if ENV['MAILINATOR_API_KEY']
      it 'creates a profile' do
        profile_request_coordinator.call
        profile_request.reload

        orcid_profile_id = profile_request.orcid_profile_id

        expect(orcid_profile_id).to match(/\w{4}-\w{4}-\w{4}-\w{4}/)

        claim_the_orcid!(random_valid_email_prefix)

        authenticate_the_orcid!(orcid_profile_id, orcid_profile_password)

        orcid_profile = Orcid::Profile.new(orcid_profile_id)

        orcid_profile.append_new_work(work)

        expect(orcid_profile.remote_works(force: true).count).to eq(1)
      end
    end

  end

  context 'appending a work to an already claimed and authorize orcid', requires_net_connect: true do
    let(:orcid_profile_id) { ENV.fetch('ORCID_CLAIMED_PROFILE_ID')}
    let(:orcid_profile_password) { ENV.fetch('ORCID_CLAIMED_PROFILE_PASSWORD')}

    before(:each) do
      expect(work).to be_valid
      authenticate_the_orcid!(orcid_profile_id, orcid_profile_password)
    end

    subject { Orcid::Profile.new(orcid_profile_id) }
    it 'should increment orcid works' do
      replacement_work = Orcid::Work.new(title: "Test Driven Orcid Integration", work_type: 'test')
      appended_work = Orcid::Work.new(title: "Another Test Drive", work_type: 'test')

      subject.replace_works_with(replacement_work)

      expect {
        subject.append_new_work(appended_work)
      }.to change { subject.remote_works(force: true).count }.by(1)

    end
  end

  # Extract this method as a proper helper
  def authenticate_the_orcid!(orcid_profile_id, orcid_profile_password)
    code = RequestSandboxAuthorizationCode.call(orcid_profile_id: orcid_profile_id, password: orcid_profile_password)
    token = Orcid.oauth_client.auth_code.get_token(code)
    normalized_token = {provider: 'orcid', uid: orcid_profile_id, credentials: {token: token.token, refresh_token: token.refresh_token }}
    Devise::MultiAuth::CaptureSuccessfulExternalAuthentication.call(user, normalized_token)
  end

  def claim_the_orcid!(email_prefix)
    $stdout.puts "Claiming an ORCID. This could take a while."
    api_token = ENV.fetch('MAILINATOR_API_KEY')

    mailbox_uri = "https://api.mailinator.com/api/inbox?to=#{email_prefix}&token=#{api_token}"

    orcid_messages = []
    mailinator_requests(mailbox_uri) do |response|
      orcid_messages = response['messages'].select {|m| m['from'] =~ /\.orcid\.org\Z/ }
      !!orcid_messages.first
    end

    orcid_message = orcid_messages.first
    raise "Unable to retrieve email for #{email_prefix}@mailinator.com" unless orcid_message

    message_uri = "https://api.mailinator.com/api/email?msgid=#{orcid_message.fetch('id')}&token=#{api_token}"
    claim_uri = nil
    mailinator_requests(message_uri) do |response|
      bodies = response.fetch('data').fetch('parts').map { |part| part.fetch('body') }
      bodies.each do |body|
        if body =~ %r{(https://sandbox.orcid.org/claim/[\w\?=]+)}
          claim_uri = $1.strip
          break
        end
      end
      claim_uri
    end

    # I have the href for the claim
    uri = URI.parse(claim_uri)
    Capybara.current_driver = :webkit
    Capybara.run_server = false
    Capybara.app_host = "#{uri.scheme}://#{uri.host}"

    visit("#{uri.path}?#{uri.query}")
    page.all('input').each do |input|
      case input[:name]
      when 'password' then input.set(orcid_profile_password)
      when 'confirmPassword' then input.set(orcid_profile_password)
      when 'acceptTermsAndConditions' then input.click
      end
    end
    page.all('button').find {|i| i.text == 'Claim' }.click
    sleep(5) # Because claiming your orcid could be slow
  end

  def mailinator_requests(uri)
    base_sleep_duration = ENV.fetch('MAILINATOR_SECONDS_TO_RETRY', 120).to_i
    retry_attempts = ENV.fetch('MAILINATOR_RETRY_ATTEMPTS', 6).to_i
    (0...retry_attempts).each do |attempt|
      sleep_duration = base_sleep_duration * (attempt +1)
      $stdout.print "\n=-=-= Connecting to Mailinator. Attempt #{attempt+1}\n\tWaiting #{sleep_duration} seconds to connect: "
      $stdout.flush
      (0...sleep_duration).each do |second|
        $stdout.print 'z' if (second % 5 == 0)
        $stdout.flush
        sleep(1)
      end
      response = JSON.parse(RestClient.get(uri, format: :json))
      if yield(response)
        $stdout.print "\n=-=-= Success on attempt #{attempt+1}. Moving on."
        $stdout.flush
        break
      end
    end
  end
end
