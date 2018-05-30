class CreateEntriesTable < ActiveRecord::Migration[5.2]
  def change
  	create_table :entries do |entry|
  		entry.string :title
  		entry.text :message
  		entry.integer :user_id
  	end
  end
end
