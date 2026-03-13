class RemovePostsFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :posts, :string
  end
end
