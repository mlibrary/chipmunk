# frozen_string_literal: true

class AddStorageVolumeToPackage < ActiveRecord::Migration[5.1]
  # To ensure that this migration runs even if Package goes away
  class Package < ActiveRecord::Base
  end

  def up
    add_column :packages, :storage_volume, :string
    Package.where.not(storage_location: nil).update_all(storage_volume: "root")
  end

  def down
    remove_column :packages, :storage_volume
  end
end
