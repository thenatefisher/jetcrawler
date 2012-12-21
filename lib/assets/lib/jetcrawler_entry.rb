class JetCrawlerEntry < JetCrawlerBase
    
    # return a constant class name
    def mapper_class

        eval self.class.to_s[0..-6].downcase.capitalize + "Map"
        
    end
    
    # return a collection
    def create_collection
    
        # all the juice
        # get the index list and paginate for all urls
        
    end
    
    # entry point
    def run
        
        # validate the entry class
        return false if !all_green
        
        # run everything through mapper
        @collection.each_with_index do |item, index| 
            m = mapper_class.new(item) 
            m.run
            @progress = (index / @collection.count).to_i.to_s + "%"
        end
        
    end
    
    # return boolean
    def all_green
        
        # create_collection && mapper_class are good
        @collection = create_collection
        @collection.class.ancestors.include? Enumerable
        mapper_class.class == Class
        
        
    end
    
    
end

