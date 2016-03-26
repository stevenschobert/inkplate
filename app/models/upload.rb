class Upload < ActiveRecord::Base

  validates_uniqueness_of :dropbox_id
  validates_presence_of :name

end
