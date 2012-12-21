class FaaEntry < JetCrawlerEntry

    def create_collection

        f = File.open(Jetcrawler::Application.config.faa_latest + "/MASTER.txt")
        output = f.read()

        return output
        
    end
    
    def source_valid?
        true
    end
    
    # entry point
    def run
               
        # validate the entry class
        return false if !all_green
        
        # run everything through mapper
        create_collection.each_line do |row| 

            aircraft = row.split(",") rescue next
  
            m = mapper_class.new(aircraft) 
            m.run
            
        end
        
    end    

end

