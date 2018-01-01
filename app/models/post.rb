class Post < ActiveRecord::Base

  validates_presence_of :slug, unless: -> { micro? }

  has_many :categorized_posts, dependent: :destroy

  enum status: [ :publish, :pending, :draft, :invisible ]
  enum kind: [ :post, :page, :micro ]

  before_validation :slugify, unless: :micro?
  before_validation :strip_title, if: :micro?

  protected

  def strip_title
    self.title = nil
  end

  def slugify
    if slug.to_s.empty?
      self.slug = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end
  end

end
