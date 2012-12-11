class Rule < ActiveRecord::Base
  attr_accessible :db, :ex_make, :ex_model, :jd_make, :jd_model, :source_id, :suggested_prefix
end
