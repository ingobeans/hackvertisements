class ChangeHackvertisementDataFromBinaryToString < ActiveRecord::Migration[8.1]
  def change
      change_column :hackvertisements, :data, :string
  end
end
