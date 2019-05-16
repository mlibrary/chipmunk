class AddStorageVolumeToPackage < ActiveRecord::Migration[5.1]
  def change
    add_column :packages, :storage_volume, :string

    Package.update_all(storage_volume: "bag:1")
  end
end
