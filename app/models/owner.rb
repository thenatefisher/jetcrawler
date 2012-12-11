class Owner < ActiveRecord::Base
  attr_accessible :address1, :address2, :airframe_id, :city, :country, :end, :name, :postal, :start, :state
end
