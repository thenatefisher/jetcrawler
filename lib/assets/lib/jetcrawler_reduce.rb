class JetCrawlerReduce < JetCrawlerBase
    
    def initialize(item)
    
        @item = item
        
    end
    
    # unique source identifier by folder name
    def source_id
    
        Source.find_or_create_by_label(self.class.to_s[0..-7].upcase).id
        
    end     
    
    # receives a hash from the mapper class
    # handles all aspects of updating the aircraft
    # source precedence
    # collissions?
    # source expiration
    # creates a change or discrepency record
    # updates target
    # profanity filter
    # required input   
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

        # convert k/v to str values
        k = k.to_s
        v = v.to_s
        
        # target_id is not a parameter to update
        # MMS and Year are not to be udpated
        whitelist = ["description", "equipment", "avionics", "ttaf", "tcaf", 
          "price", "registration", "location", "inspection", "interior", 
          "exterior", "seller", "damage", "engines", "owners"]
          
        next if !whitelist.include?(k)

        # if this k/v equals the current param value,
        # do nothing
        next if target[k.to_sym] == v

        # if latest change record from this source
        # has same values as this k/v, do nothing
        next if target.changes.find(
          :first, 
          :conditions => [
            "field = ? AND value = ? AND source_id = ?", 
            k, v, self.source_id
            ],
          :order => "created_at DESC"
        ).present?
        
        # find last change that was not a conflict
        last_change = target.changes.find(
          :first, 
          :conditions => [
            "field = ? AND conflict_id IS NULL", k],
          :order => "created_at DESC"
        )
                  
        # if none, create a change
        if last_change.nil?
        
          new_change = Change.create({
            :target_id => target.id, 
            :field => k, 
            :source_id => self.source_id, 
            :value => v
            })
            
        else # otherwise, it gets sticky...
          
            # get self source priority
            self_priority = FieldPriority.where(
              :source_id => self.source_id, 
              :field => k).priority rescue 99
            
            # get last change source priority
            last_change_priority = FieldPriority.where(
              :source_id => last_change.source_id, 
              :field => k).priority rescue 99  
              
            # if last change was a higher pri, make a new conflict CR
            if last_change_priority > self_priority
            
              Change.create({
                :target_id => target.id, 
                :field => k, 
                :source_id => self.source_id, 
                :value => v,
                :conflict_id => last_change.id
              }) 
              
            else # if last change was equal or lower priority
            
              # create a new change
              new_change = Change.create({
                :target_id => target.id, 
                :field => k, 
                :source_id => self.source_id, 
                :value => v
              }) 
                        
              # make last change a conflict CR
              last_change.conflict_id = new_change.id
              last_change.save
            
            end        

        end

    end   

end

end
