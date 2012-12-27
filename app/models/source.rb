class Source < ActiveRecord::Base
  attr_accessible :latest, :name
  has_many :field_priorities
end
