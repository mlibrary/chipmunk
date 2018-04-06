# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.references :bag, foreign_key: true
      t.string :event_type
      t.references :user, foreign_key: true
      t.string :outcome
      t.string :detail

      t.timestamps
    end
  end
end
