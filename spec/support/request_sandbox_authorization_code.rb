require 'rest_client'
class RequestSandboxAuthorizationCode

  def self.call(options = {}, config = {})
    new(config).call(options)
  end

  attr_reader :cookies, :access_scope, :authorize_url, :login_url
  attr_reader :oauth_redirect_uri, :orcid_client_id, :authorization_code, :orcid_client_secret

  def initialize(options = {})
    @orcid_client_id = options.fetch(:orcid_client_id) { ENV['ORCID_APP_ID']}
    @orcid_client_secret = options.fetch(:orcid_client_secret) { ENV['ORCID_APP_SECRET']}
    @login_url = options.fetch(:login_url) { ENV['ORCID_REMOTE_LOGIN_URL'] || 'https://sandbox-1.orcid.org/signin/auth.json'}
    @authorize_url = options.fetch(:authorize_url) { ENV['ORCID_AUTHORIZE_URL'] || 'https://sandbox-1.orcid.org/oauth/authorize' }
    @oauth_redirect_uri = options.fetch(:oauth_redirect_uri) { 'https://developers.google.com/oauthplayground' }
    @access_scope = options.fetch(:scope) { ENV['ORCID_APP_AUTHENTICATION_SCOPE'] }
  end

  def call(options = {})
    orcid_profile_id = options.fetch(:orcid_profile_id) { ENV['ORCID_CLAIMED_PROFILE_ID'] }
    password = options.fetch(:password) { ENV['ORCID_CLAIMED_PROFILE_PASSWORD']}

    login_to_orcid(orcid_profile_id, password)
    request_authorization
    request_authorization_code
  end

  attr_writer :cookies
  private :cookies

  private
  def login_to_orcid(orcid_profile_id, password)
    response = RestClient.post(login_url, userId: orcid_profile_id, password: password )
    if ! JSON.parse(response)["success"]
      raise "Response not successful: \n#{response}"
    else
      self.cookies = response.cookies
    end
  end

  def request_authorization
    parameters = { client_id: orcid_client_id, response_type: 'code', scope: access_scope, redirect_uri: oauth_redirect_uri }
    RestClient.get(authorize_url, {params: parameters, cookies: cookies})
  end

  def request_authorization_code
    RestClient.post(authorize_url, {user_oauth_approval: true}, {cookies: cookies})
  rescue RestClient::Found => e
    uri = URI.parse(e.response.headers.fetch(:location))
    CGI::parse(uri.query).fetch('code').first
  end

end
