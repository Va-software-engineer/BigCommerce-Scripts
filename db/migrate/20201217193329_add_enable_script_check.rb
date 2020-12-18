class AddEnableScriptCheck < ActiveRecord::Migration[6.0]
  def change
    change_table :stores do |t|
      t.boolean :enabled_scripts, default: false
    end
  end
end
