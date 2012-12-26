class FaaReduce < JetCrawlerReduce

    def run
    
      # get target record
      target = Target.find(@item[:target_id])
      return false if target.blank?
      
      # is item already the same in target record?
      # if not, what was the last change record for this param/value which 
      #   was not a conflict
      # does that change record have a higher priority source?
      # make a change record      
      @item.each do |k,v|
        
        next if target[k.to_sym] == v
        
        target[k.to_sym] = v
      
      end  
    
    end

end
