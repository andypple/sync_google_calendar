class AddGoogleCredentialsToUsers < ActiveRecord::Migration[6.1]
  def change
    change_table :users, bulk: true do |t|
      t.column :token, :string
      t.column :refresh_token, :string
      t.column :expires_at, :datetime
    end
  end
end
