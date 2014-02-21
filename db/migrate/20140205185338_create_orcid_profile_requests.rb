class CreateOrcidProfileRequests < ActiveRecord::Migration
  def change
    create_table :orcid_profile_requests do |t|
      t.integer :user_id, unique: true, index: true, null: false
      t.string :given_names, null: false
      t.string :family_name, null: false
      t.string :primary_email, null: false
      t.string :orcid_profile_id, unique: true, index: true
      t.timestamps
    end
  end
end
