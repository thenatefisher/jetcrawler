class Target < ActiveRecord::Base

    attr_accessible :make, :model_name, :registration, :serial, :tcaf, :ttaf, 
                    :year, :serial_integer

end
