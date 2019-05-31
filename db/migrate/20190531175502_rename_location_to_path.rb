class RenameLocationToPath < ActiveRecord::Migration[5.1]
  def change
    rename_column :packages, :storage_location, :storage_path
  end
end
