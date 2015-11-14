class CreateCategorizedPosts < ActiveRecord::Migration
  def up
    create_table :categorized_posts do |t|
      t.integer :category_id
      t.integer :post_id
    end

    add_index :categorized_posts, :category_id
    add_index :categorized_posts, :post_id
  end

  def down
    drop_table :categorized_posts
  end
end
