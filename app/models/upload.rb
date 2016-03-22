class Upload < ActiveRecord::Base

  validates_uniqueness_of :dropbox_id

end
