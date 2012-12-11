class Airframe < ActiveRecord::Base
  attr_accessible :make, :model_name, :registration, :serial, :tc, :tt, :year, :serial_iterator
  
end
