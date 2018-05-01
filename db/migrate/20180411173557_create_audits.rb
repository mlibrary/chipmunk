# frozen_string_literal: true

class CreateAudits < ActiveRecord::Migration[5.1]
  def change
    create_table :audits do |t|
      t.references :user, foreign_key: true
      t.integer :packages

      t.timestamps
    end

    add_reference :events, :audit, foreign_key: true
  end
end
