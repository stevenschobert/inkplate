class Post < ActiveRecord::Base

  validates_presence_of :slug

  has_many :categorized_posts, dependent: :destroy

  enum status: [ :publish, :pending, :draft, :invisible ]
  enum kind: [ :post, :page ]

end
