class CreateDeposits < ActiveRecord::Migration[5.1]
  def change
    create_table :deposits do |t|
      t.references :artifact, null: false, index: false
      t.references :user, null: false, index: false
      t.string :status, null: false
      t.timestamps
    end

    add_index :deposits, :user_id, unique: false
    add_foreign_key :deposits, :artifacts
    add_foreign_key :deposits, :users
  end
end
