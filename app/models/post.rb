class Post < ActiveRecord::Base

  has_many :categorized_posts, dependent: :destroy

end
