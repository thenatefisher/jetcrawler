model priorities

  def set_defaults
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
  end

  def create_priority(field_name, priority_list)

    Source.all.each do |source|

      priority = priority_list.index(source.name.downcase) rescue nil
      
      next if priority.blank?
      
      values = {
        :source_id => source.id,
        :field => field_name,
        :priority => priority
      }
        
      FieldPriority.where(values.strip(:source_id, :field)) ||
        FieldPriority.create(values)
        
    end
    
  end

end
