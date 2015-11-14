class CategorizedPost < ActiveRecord::Base

  validates_presence_of :category_id
  validates_presence_of :post_id

end
