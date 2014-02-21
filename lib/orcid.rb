require 'orcid/engine'
require 'orcid/configuration'
require 'mappy'
require 'devise_multi_auth'
require 'virtus'
require 'omniauth-orcid'
require 'email_validator'
require 'simple_form'

module Orcid

  class << self
    attr_accessor :configuration
  end

  module_function
  def configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def provider_name
    configuration.provider_name
  end

  def authentication_model
    configuration.authentication_model
  end


  def connect_user_and_orcid_profile(user, orcid_profile_id, options = {})
    authentication_model.create!(provider: provider_name, uid: orcid_profile_id, user: user)
  end

  def access_token_for(orcid_profile_id, options = {})
    client = options.fetch(:client) { oauth_client }
    tokenizer = options.fetch(:tokenizer) { authentication_model }
    tokenizer.to_access_token(uid: orcid_profile_id, provider: provider_name, client: client)
  end

  def profile_for(user)
    if auth = authentication_model.where(provider: provider_name, user: user).first
      Orcid::Profile.new(auth.uid)
    else
      nil
    end
  end

  def enqueue(object)
    object.run
  end

  def oauth_client
    # passing the site: option as Orcid's Sandbox has an invalid certificate
    # for the api.sandbox-1.orcid.org
    @oauth_client ||= Devise::MultiAuth.oauth_client_for(
      provider_name, options: { site: ENV['ORCID_SITE_URL']}
    )
  end

  def client_credentials_token(scope, options = {})
    tokenizer = options.fetch(:tokenizer) { oauth_client.client_credentials }
    tokenizer.get_token(scope: scope)
  end

end
