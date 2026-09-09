# frozen_string_literal: true

class CreateEmailSignatures < ActiveRecord::Migration[8.1]
  def change
    create_table :email_signatures do |t|
      t.references :account, null: false, foreign_key: true, index: false
      t.string :email, null: false
      t.string :kind, null: false
      t.references :blob, null: false, foreign_key: { to_table: :active_storage_blobs }, index: true
      t.timestamps
    end

    add_index :email_signatures, %i[account_id email kind], unique: true
  end
end
