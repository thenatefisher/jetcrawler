class CcarEntry < JetCrawlerEntry

    def create_collection

        # scope and initialize
        output = nil
        upload_date = DateTime.new
        
        db_file_url = "http://wwwapps2.tc.gc.ca/Saf-Sec-Sur/2/ccarcs/download/ccarcsdb.zip"

          # store old database file if one exists
          latest_dir = File.expand_path(File.join(Jetcrawler::Application.config.registers, "ccar", "latest"))
          latest_file_path = File.expand_path(Dir.glob(File.join(latest_dir, "*.zip")).first) rescue nil
          FileUtils.cp latest_file_path File.join(Jetcrawler::Application.config.registers, "ccar", "archive", ".") rescue nil
          
          # remove old files
          FileUtils.rm Dir.glob(File.join(latest_dir, "*")) rescue nil
          
          # get latest database archive
          Dir.chdir(latest_dir)
          `wget #{db_file_url}`
          
          # unpack it
          latest_file_path = File.expand_path(Dir.glob(File.join(latest_dir, "*.zip")).first)
          `unzip #{latest_file_path}`

          # ensure all files are present
          ccar_master  = File.expand_path(File.join(latest_dir, "Carscurr.txt"))
          ccar_owner   = File.expand_path(File.join(latest_dir, "Carsownr.txt"))
                    
          return output if !File.exists?(ccar_master) ||
            !File.exists?(ccar_owner)
                   
          # record latest db date
          self.latest_database_touch
          
          # read database file into mapper
          master_handler = File.open(ccar_master)
          output = master_handler.read
          
        
        return output
        
    end
    
    def source_valid?
        true
    end
    
    # entry point
    def run
               
        # validate the entry class
        return false if !all_green || @collection.blank?
        
        # run everything through mapper
        @collection.each_line do |row| 

            aircraft = row.split(",") rescue next
  
            m = mapper_class.new(aircraft) 
            m.run
            
        end
       end
 
end    


