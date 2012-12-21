class Translation < ActiveRecord::Base
  attr_accessible :token, :target_id, :source_id
end
