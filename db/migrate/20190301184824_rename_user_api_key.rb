# frozen_string_literal: true

class RenameUserApiKey < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :api_key_digest, :string, default: "x", null: false
    User.all.each do |user|
      user.update_column(
        :api_key_digest,
        Keycard::DigestKey.new(key: user.read_attribute(:api_key)).digest
      )
    end
    remove_column :users, :api_key
    change_column_default :users, :api_key_digest, nil
  end

  def down
    message = "This migration cannot be rolled back. The raw api_keys are lost."
    say message
    raise message
  end
end
