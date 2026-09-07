class CreateVaultsAndNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :vaults, id: false do |t|
      t.string :id, primary_key: true
      t.string :name, null: false
      t.string :api_key, null: false
      t.timestamps
    end
    add_index :vaults, :api_key, unique: true

    create_table :notes, id: false do |t|
      t.string :id, primary_key: true
      t.string :vault_id, null: false
      t.string :relative_path, null: false
      t.text :encrypted_body, null: false
      t.json :frontmatter, default: {}
      t.string :content_hash, null: false
      t.integer :version, default: 1, null: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :notes, [:vault_id, :relative_path], unique: true
    add_index :notes, :vault_id
    add_index :notes, :updated_at
    add_index :notes, :deleted_at
  end
end
