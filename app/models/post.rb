class Post < ActiveRecord::Base

  has_many :categorized_posts, dependent: :destroy

  enum status: [ :publish, :pending, :draft, :invisible ]

end
