require 'net/http'
module Orcid
	class CreateProfileController < Orcid::ApplicationController
		respond_to :html

		def create
      byebug
			uri = URI.parse("https://sandbox.orcid.org/oauth/token") 
			request = Net::HTTP::Post.new(uri) request["Accept"] = "application/json" 
			request.set_form_data( "client_id" => "APP-DUCNNE8KZ3DGLI66", 
									           "client_secret" => "9826e131-91eb-414c-814f-7b414e65e1e4", 
									           "grant_type" => "authorization_code", 
									           "code" => params[:code], 
									           "redirect_uri" => "http://localhost:3000") 
			response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http| 
				http.request(request) 
			end

		end
	end
end