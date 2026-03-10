class AddPostIdsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :posts, :string
  end
end
