class Change < ActiveRecord::Base
  attr_accessible :field, :source_id, :value, :target_id
  belongs_to :target
end
