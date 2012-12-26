class JetCrawlerReduce < JetCrawlerBase
    
    def initialize(item)
    
        @item = item
        
    end
    
    # unique source identifier by folder name
    def source_id
    
        Source.find_or_create_by_label(self.class.to_s[0..-7].upcase).id
        
    end     
    
    def run
    
    # receives a hash from the mapper class
    # handles all aspects of updating the aircraft
    # source precedence
    # collissions?
    # source expiration
    # creates a change or discrepency record
    # updates target
    # profanity filter
    # required input    

    end   

end
