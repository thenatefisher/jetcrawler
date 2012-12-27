class FieldPriority < ActiveRecord::Base
  attr_accessible :field, :priority, :source_id
  belongs_to :source
end
