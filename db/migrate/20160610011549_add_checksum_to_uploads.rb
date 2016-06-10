class AddChecksumToUploads < ActiveRecord::Migration
  def up
    add_column :uploads, :checksum, :text
  end

  def down
    remove_column :uploads, :checksum
  end
end
