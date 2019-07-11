# frozen_string_literal: true

class CreateQueueItems < ActiveRecord::Migration[5.1]
  def change
    create_table :queue_items do |t|
      t.references :request, null: false, index: false
      t.references :bag, null: true, index: false
      t.integer :status, null: false, default: 0
      t.text :error, null: true
      t.timestamps
    end

    add_index :queue_items, :bag_id, unique: false
    add_foreign_key :queue_items, :bags

    add_index :queue_items, :request_id, unique: true
    add_foreign_key :queue_items, :requests
  end
end
