class RemoveDateFromHackvertisements < ActiveRecord::Migration[8.1]
  def change
    remove_column :hackvertisements, :date, :date
  end
end
