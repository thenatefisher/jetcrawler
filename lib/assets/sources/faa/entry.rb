class FaaEntry < JetCrawlerEntry

    def create_collection

        # scope and initialize
        output = nil
        upload_date = DateTime.new
        
        # check if new db exists
        # from http://www.faa.gov/licenses_certificates/aircraft_certification/aircraft_registry/releasable_aircraft_download/
        response = `curl "http://registry.faa.gov/aircraftdownload/" 2> /dev/null` rescue nil
        db_file_url = response.match(/(http[^"]*)/)[1] rescue nil
        upload_date_string = response.match(/UploadDate = "([^"]*)/)[1] rescue nil
        upload_date = DateTime.strptime(upload_date_string, '%B %d, %Y') rescue DateTime.new
        
        if self.latest_database_date.blank? || self.latest_database_date < upload_date
          
          # store old database file if one exists
          latest_dir = File.expand_path(File.join(Jetcrawler::Application.config.registers, "faa", "latest"))
          latest_file_path = File.expand_path(Dir.glob(File.join(latest_dir, "*.zip")).first) rescue nil
          latest_file_name = latest_file_path.match(/\/([^\/]*)$/)[1] rescue nil
          remote_file_name = db_file_url.match(/\/([^\/]*)$/)[1] rescue nil
          
          if latest_file_name != remote_file_name
          
            FileUtils.cp latest_file_path File.join(Jetcrawler::Application.config.registers, "faa", "archive", ".") rescue nil
            
            # remove old files
            FileUtils.rm Dir.glob(File.join(latest_dir, "*")) rescue nil
            
            # get latest database archive
            Dir.chdir(latest_dir)
            `wget #{db_file_url} 2> /dev/null`
            
            # unpack it
            latest_file_path = File.expand_path(Dir.glob(File.join(latest_dir, "*.zip")).first)
            `unzip -o #{latest_file_path} 2> /dev/null`
            
          end
          
          # ensure all files are present
          faa_master  = File.expand_path(File.join(latest_dir, "MASTER.txt"))
          faa_dereg   = File.expand_path(File.join(latest_dir, "DEREG.txt"))
          faa_engine  = File.expand_path(File.join(latest_dir, "ENGINE.txt"))
          faa_acftref = File.expand_path(File.join(latest_dir, "ACFTREF.txt"))
                    
          return output if !File.exists?(faa_master) ||
            !File.exists?(faa_dereg) ||
            !File.exists?(faa_engine) ||
            !File.exists?(faa_acftref)
                   
          # record latest db date
          self.latest_database_touch
          
          # read database file into mapper
          faa_master_handler = File.open(faa_master)
          output = faa_master_handler.read
          
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
        return false if !all_green || @collection.blank?
        
        progress = ProgressBar.create(
          :title => "Mapping " + self.class.to_s[0..-6],
          :total => @collection.count)  
                  
        # run everything through mapper
        @collection.each_line do |row| 

            aircraft = row.split(",") rescue next
  
            m = mapper_class.new(aircraft) 
            m.run
            
            progress.increment
            
        end
        
        progress.finish
        
    end    

end

