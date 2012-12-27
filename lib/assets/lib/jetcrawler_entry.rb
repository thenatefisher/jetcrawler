class JetCrawlerEntry < JetCrawlerBase
    
    def latest_database_date 
    
       Source.find(source_id).latest
    
    end
    
    def latest_database_touch
    
      source = Source.find(source_id)
      source.latest = Time.now
      source.save
    
    end
    
    # unique source identifier by folder name
    def source_id
    
        Source.find_or_create_by_label(self.class.to_s[0..-6].upcase).id
        
    end
    
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
        
        progress = ProgressBar.create(
          :title => "Mapping " + self.class.to_s[0..-6],
          :total => @collection.count)        
        
        # run everything through mapper
        @collection.each_with_index do |item, index| 
            m = mapper_class.new(item) 
            m.run
            progress.increment
        end
        
        progress.finish
        
    end
    
    # return boolean
    def all_green
        
        # create_collection && mapper_class are good
        @collection = create_collection
        @collection.class.ancestors.include? Enumerable
        mapper_class.class == Class
        
        
    end
    
    
end

