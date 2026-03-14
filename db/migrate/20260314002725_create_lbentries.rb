class CreateLbentries < ActiveRecord::Migration[8.1]
  def change
    create_table :lbentries do |t|
      t.string :name
      t.integer :hits

      t.timestamps
    end
  end
end
