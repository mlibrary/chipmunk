# frozen_string_literal: true

class AddFormatToPackage < ActiveRecord::Migration[5.1]
  def change
    add_column :packages, :format, :string, default: "bag", null: false
  end
end
