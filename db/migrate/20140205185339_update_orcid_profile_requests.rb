class UpdateOrcidProfileRequests < ActiveRecord::Migration
  def change
    add_column :orcid_profile_requests, :response_text, :text
    add_column :orcid_profile_requests, :response_status, :string, index: true
  end
end
