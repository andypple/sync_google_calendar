class CreateEventsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.string :gid, index: { unique: true, name: 'unique_gid' }
      t.datetime :start
      t.datetime :end
      t.string :summary
      t.text :description
      t.references :user

      t.timestamps
    end
  end
end
