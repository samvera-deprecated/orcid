module Orcid::OnDemandUrlHelper 
  def on_demand_url(user)
    "#{Orcid.provider.authorize_url}?client_id=#{ENV['ORCID_APP_ID']}&response_type=code&scope=/authenticate&redirect_uri=#{orcid.create_orcid_url}&family_names=#{user.last_name if user.respond_to? :last_name }&given_names=#{user.first_name if user.respond_to? :first_name }&email=#{user.email}"
  end
end
