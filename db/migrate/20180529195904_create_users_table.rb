class CreateUsersTable < ActiveRecord::Migration[5.2]
  def change
  	create_table :users do |user|
  		user.string :first_name
  		user.string :last_name
  		user.string :email
  		user.string :password
        user.string :nickname
  	end
  end
end
