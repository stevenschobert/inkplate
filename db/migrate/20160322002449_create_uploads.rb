class CreateUploads < ActiveRecord::Migration
  def up
    create_table :uploads do |t|
      t.string :name
      t.string :mime_type
      t.integer :size

      t.string :dropbox_url
      t.string :dropbox_id
      t.string :dropbox_path
      t.string :dropbox_rev
    end

    add_index :uploads, :dropbox_id, unique: true
    add_index :uploads, :dropbox_url
  end

  def down
    remove_index :uploads, :dropbox_id
    remove_index :uploads, :dropbox_url
  end
end
