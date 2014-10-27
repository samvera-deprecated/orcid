require 'rest_client'

# This follows the instructions from:
# http://support.orcid.org/knowledgebase/articles/179969-methods-to-generate-an-access-token-for-testing#curl
class RequestSandboxAuthorizationCode

  def self.call(options = {})
    new(options).call
  end

  attr_reader :cookies, :access_scope, :authorize_url, :login_url
  attr_reader :oauth_redirect_uri, :orcid_client_id, :authorization_code, :orcid_client_secret
  attr_reader :orcid_profile_id, :password

  def initialize(options = {})
    @orcid_client_id = options.fetch(:orcid_client_id) { Orcid.provider.id }
    @orcid_client_secret = options.fetch(:orcid_client_secret) { Orcid.provider.secret }
    @login_url = options.fetch(:login_url) { Orcid.provider.signin_via_json_url }
    @authorize_url = options.fetch(:authorize_url) { Orcid.provider.authorize_url }
    @oauth_redirect_uri = options.fetch(:oauth_redirect_uri) { 'https://developers.google.com/oauthplayground' }
    @access_scope = options.fetch(:scope) { Orcid.provider.authentication_scope }
    @orcid_profile_id = options.fetch(:orcid_profile_id) { ENV['ORCID_CLAIMED_PROFILE_ID'] }
    @password = options.fetch(:password) { ENV['ORCID_CLAIMED_PROFILE_PASSWORD'] }
  end

  def call
    puts "Attempting to login to orcid { PROFILE_ID: '#{orcid_profile_id}', PASSWORD: '#{password}' }"
    login_to_orcid
    request_authorization
    request_authorization_code
  end

  attr_writer :cookies
  private :cookies

  private

  def custom_authorization_url
    authorize_url.sub('oauth/authorize', 'oauth/custom/authorize.json')
  end

  def resource_options
    { ssl_version: :SSLv23 }.tap {|options|
      options[:headers] = { cookies: cookies } if cookies
    }
  end

  def login_to_orcid
    resource = RestClient::Resource.new(login_url, resource_options)
    response = resource.post({ userId: orcid_profile_id, password: password })
    if JSON.parse(response)['success']
      self.cookies = response.cookies
    else
      fail "Response not successful: \n#{response}"
    end
  end

  def request_authorization
    parameters = {
      client_id: orcid_client_id,
      response_type: 'code',
      scope: access_scope,
      redirect_uri: oauth_redirect_uri
    }
    resource = RestClient::Resource.new("#{authorize_url}?#{parameters.to_query}", resource_options)
    response = resource.get
    response
  end

  def request_authorization_code
    options = resource_options
    options[:headers] ||= {}
    options[:headers][:content_type] = :json
    options[:headers][:accept] = :json
    resource = RestClient::Resource.new(custom_authorization_url, options)
    response = resource.post(authorization_code_payload.to_json)
    json = JSON.parse(response)
    redirected_to = json.fetch('redirectUri').fetch('value')
    uri = URI.parse(redirected_to)
    CGI.parse(uri.query).fetch('code').first
  rescue RestClient::Exception => e
    File.open("/Users/jfriesen/Desktop/orcid.html", 'w+') {|f| f.puts e.response.body.force_encoding('UTF-8') }
    $stderr.puts "Response Code: #{e.response.code}\n\tCookies: #{cookies.inspect}\n\tAuthorizeURL: #{authorize_url.inspect}"
    raise e
  end

  def authorization_code_payload
    {
      "errors" => [],
      "userName" => {
        "errors" => [],
        "value" => "",
        "required" => true,
        "getRequiredMessage" => nil
      },
      "password" => {
        "errors" => [],
        "value" => "",
        "required" => true,
        "getRequiredMessage" => nil
      },
      "clientId" => {
        "errors" => [],
        "value" => "#{orcid_client_id}",
        "required" => true,
        "getRequiredMessage" => nil
      },
      "redirectUri" => {
        "errors" => [],
        "value" => "=#{URI.escape(oauth_redirect_uri)}",
        "required" => true,
        "getRequiredMessage" => nil
      },
      "scope" => {
        "errors" => [],
        "value" => "#{access_scope}",
        "required" => true,
        "getRequiredMessage" => nil
      },
      "responseType" => {
        "errors" => [],
        "value" => "code",
        "required" => true,
        "getRequiredMessage" => nil
      },
      "approved" => true,
      "persistentTokenEnabled" => false
    }
  end

end
