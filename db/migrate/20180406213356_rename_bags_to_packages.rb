# frozen_string_literal: true

class RenameBagsToPackages < ActiveRecord::Migration[5.1]
  def change
    rename_table :bags, :packages
    rename_column :events, :bag_id, :package_id
    rename_column :queue_items, :bag_id, :package_id
  end
end
