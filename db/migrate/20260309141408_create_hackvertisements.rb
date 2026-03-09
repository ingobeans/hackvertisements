class CreateHackvertisements < ActiveRecord::Migration[8.1]
  def change
    create_table :hackvertisements do |t|
      t.string :user_id
      t.date :date
      t.binary :data
      t.string :link

      t.timestamps
    end
  end
end
