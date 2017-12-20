class Post < ActiveRecord::Base

  validates_presence_of :slug, unless: -> { micro? }

  has_many :categorized_posts, dependent: :destroy

  enum status: [ :publish, :pending, :draft, :invisible ]
  enum kind: [ :post, :page, :micro ]

end
