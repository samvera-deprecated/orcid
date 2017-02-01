module Orcid::OnDemandUrlHelper 
  def on_demand_url(user)
    connector_params = {
      client_id: ENV['ORCID_APP_ID'],
      response_type: 'code',
      scope: Orcid.provider.authentication_scope,
      redirect_uri: orcid.create_orcid_url,
      family_names: (user.last_name if user.respond_to? :last_name),
      given_names: (user.first_name if user.respond_to? :first_name),
      email: user.email
    }  

    "#{Orcid.provider.authorize_url}?#{connector_params.to_query}"
  end
end
