class AddSriptTagProperty < ActiveRecord::Migration[6.0]
  def change
    change_table :stores do |t|
      t.string :property_id
    end
  end
end
