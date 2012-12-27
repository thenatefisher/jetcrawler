
class AmstatEntry < JetCrawlerEntry

    def create_collection

        output = IO.read(Jetcrawler::Application.config.amstat + "/MMS.csv").force_encoding("ISO-8859-1").encode("utf-8", replace: nil) 

        # record latest db date
        self.latest_database_touch

        return output
        
    end
    
    def source_valid?
        true
    end
    
    # entry point
    def run
              
        # validate the entry class
        return false if !all_green

        progress = ProgressBar.create(
          :title => "Mapping " + self.class.to_s[0..-6],
          :total => @collection.split("\n").count)  

        # run everything through mapper
        @collection.each_line do |row| 

            aircraft = row.split(";") rescue next

            next if aircraft[1].nil? ||
                aircraft[2].nil? ||
                aircraft[3].nil? ||
                aircraft[4].nil? ||
                aircraft[5].nil? 
  
            m = mapper_class.new(aircraft) 
            m.run
            
            progress.increment
            
        end
        
        progress.finish
        
    end    

end

