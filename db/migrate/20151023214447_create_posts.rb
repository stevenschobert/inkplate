class CreatePosts < ActiveRecord::Migration
  def up
    create_table :posts do |t|
      t.integer :status, default: 0

      t.string  :title
      t.string  :slug

      t.text    :excerpt
      t.text    :more_text
      t.text    :body

      t.json    :custom_fields

      t.timestamps null: false
    end

    add_index :posts, :status
  end

  def down
    remove_index :posts, :status
    drop_table :posts
  end
end
