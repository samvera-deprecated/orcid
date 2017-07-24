require 'net/http'
module Orcid
  class CreateProfileController < Orcid::ApplicationController
    respond_to :html
    before_filter :authenticate_user!

    def create
      uri = URI.parse(Orcid.provider.token_url)

      request = Net::HTTP::Post.new(uri)
      request["Accept"] = "application/json"
      request.set_form_data( "client_id" => ENV['ORCID_APP_ID'],
           "client_secret" => ENV['ORCID_APP_SECRET'],
           "grant_type" => "authorization_code",
           "code" => params[:code],
           "redirect_uri" => config.application_root_url ) 
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end

      redirect_to(user_omniauth_authorize_path(:orcid))
    end
  end
end
