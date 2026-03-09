class AddProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :pfp, :string
  end
end
