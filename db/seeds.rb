# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def create_priority(field_name, priority_list)

  Source.all.each do |source|

    priority = priority_list.index(source.label.downcase) rescue nil
    
    priority = 99 if priority.blank?
    
    values = {
      :source_id => source.id,
      :field => field_name
    }
      
    fp = FieldPriority.where(values).first
    fp ||= FieldPriority.create(values)
      
    fp.priority = priority
    fp.save  
      
  end
  
end

create_priority("location",   ["controller","aso","tap","faa","ccar","amstat"])
create_priority("ttaf",       ["faa","ccar","controller","aso","tap","amstat"])
create_priority("tcaf",       ["faa","ccar","controller","aso","tap","amstat"])
create_priority("equipment",  ["faa","ccar","controller","aso","tap","amstat"])
create_priority("avionics",   ["faa","ccar","controller","aso","tap","amstat"])
create_priority("interior",   ["faa","ccar","controller","aso","tap","amstat"])
create_priority("exterior",   ["faa","ccar","controller","aso","tap","amstat"])
create_priority("inspection", ["faa","ccar","controller","aso","tap","amstat"])
create_priority("owners",     ["faa","ccar","controller","aso","tap","amstat"])
create_priority("seller",     ["controller","aso","tap","amstat"])
create_priority("engines",    ["controller","aso","tap","amstat","faa","ccar"])
create_priority("image_urls", ["faa","ccar","controller","aso","tap","amstat"])
create_priority("price",      ["controller","aso","tap","amstat"])
create_priority("damage",     ["ntsb","faa","ccar","amstat","controller","aso","tap"])
create_priority("description",["controller","aso","tap","amstat"])
