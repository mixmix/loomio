class AddMembershipsCount < ActiveRecord::Migration
  def up
  	add_column :users, :memberships_count, :integer, :default => 0, :null => false
  	User.reset_column_information
  	User.all.each do |user|
  		user.memberships_count = user.memberships.count
  		user.save!
  	end
  end

  def down
  	remove_column :users, :memberships_count
  end
end