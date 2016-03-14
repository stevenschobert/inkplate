class CreatePosts < ActiveRecord::Migration
  def up
    create_table :posts do |t|
      t.integer :status, default: 0
      t.integer :kind, default: 0

      t.string  :title
      t.string  :slug

      t.text    :excerpt
      t.text    :more_text
      t.text    :body

      t.json    :custom_fields

      t.timestamps null: false
    end

    add_index :posts, :status
    add_index :posts, :kind
  end

  def down
    remove_index :posts, :status
    remove_index :posts, :kind
    drop_table :posts
  end
end
