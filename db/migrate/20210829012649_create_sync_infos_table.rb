class CreateSyncInfosTable < ActiveRecord::Migration[6.1]
  def change
    create_table :sync_infos do |t|
      t.string :page_token
      t.string :sync_token
      t.references :user

      t.timestamps
    end
  end
end
