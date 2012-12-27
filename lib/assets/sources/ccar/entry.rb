class CcarEntry < JetCrawlerEntry

    def create_collection

        # scope and initialize
        output = nil
        upload_date = DateTime.new
        
        if self.latest_database_date.blank? || self.latest_database_date < 7.days.ago
        
          db_file_url = "http://wwwapps2.tc.gc.ca/Saf-Sec-Sur/2/ccarcs/download/ccarcsdb.zip"

          # store old database file if one exists
          latest_dir = File.expand_path(File.join(Jetcrawler::Application.config.registers, "ccar", "latest"))
          latest_file_path = File.expand_path(Dir.glob(File.join(latest_dir, "*.zip")).first) rescue nil
          FileUtils.cp latest_file_path File.join(Jetcrawler::Application.config.registers, "ccar", "archive", ".") rescue nil

          # remove old files
          FileUtils.rm Dir.glob(File.join(latest_dir, "*")) rescue nil
          
          # get latest database archive
          Dir.chdir(latest_dir)
          `wget #{db_file_url} 2> /dev/null`
          
          # unpack it
          latest_file_path = File.expand_path(Dir.glob(File.join(latest_dir, "*.zip")).first)
          `unzip -o #{latest_file_path} 2> /dev/null`

          # ensure all files are present
          ccar_master  = File.expand_path(File.join(latest_dir, "carscurr.txt"))
          ccar_owner   = File.expand_path(File.join(latest_dir, "carsownr.txt"))
                    
          return output if !File.exists?(ccar_master) ||
            !File.exists?(ccar_owner)
      
          # record latest db date
          self.latest_database_touch
          
          # read database file into mapper
          output = IO.read(ccar_master).force_encoding("ISO-8859-1").encode("utf-8", replace: nil);
          
        else
          
          puts "Local DB is not due for check, skipping"
        
        end
        
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

            aircraft = row.split("\",\"") rescue next

            m = mapper_class.new(aircraft) 
            m.run
            
            progress.increment

        end
        
        progress.finish
        
    end
 
end    


