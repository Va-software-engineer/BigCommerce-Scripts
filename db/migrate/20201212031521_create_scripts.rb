class CreateScripts < ActiveRecord::Migration[6.0]
  def change
    create_table :scripts do |t|
      t.references :store
      t.string :name
      t.string :pages
      t.string :location
      t.boolean :status, default: false
      t.string :uuid
      t.string :api_client_id
      t.timestamps
    end
  end
end
