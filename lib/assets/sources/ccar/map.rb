class CcarMap < JetCrawlerMap
        
    # parse html input, return type Target
    def parse_input
        
        latest_dir = File.expand_path(File.join(Jetcrawler::Application.config.registers, "ccar", "latest"))
        ccar_owner   = File.expand_path(File.join(latest_dir, "carsownr.txt"))

        source_data = Hash.new

        @item.each_with_index { |d,i| @item[i] = d.gsub(/"/,"").strip rescue nil }
        
        if !@item[0].blank? &&   
          !@item[6].blank? &&
          !@item[3].blank? &&
          !@item[4].blank? &&
          @item[10] == "Aeroplane" &&
          (
            @item[15] == "Turbo Fan" ||
            @item[15] == "Turbo Jet" ||
            @item[15] == "Turbo Prop" ||
            @item[15] == "Turbo Shaft"
          )

          registration   = "C-"+@item[0]
          serial         = @item[6]
          make           = @item[3]
          year           = @item[31][0..4].to_i rescue nil
	        model_name     = @item[4]
          
          location       = @item[32] rescue nil
          if !@item[34].blank? && !@item[32].blank?
            location       = "#{@item[34]}, #{@item[32]}" 
          end

          owners = Array.new
          grep_query = `cat #{ccar_owner} | grep "\"#{@item[0]}\""`
          grep_query = grep_query.force_encoding("ISO-8859-1").encode("utf-8", replace: nil);
          grep_query.each_line do |row|
            
            owner_record = row.split("\",\"")
            next if owner_record.nil?
            
            owner_record.each_with_index { |d,i| owner_record[i] = d.gsub(/"/,"").strip rescue nil }
            
            type    = owner_record[11] rescue nil
            name    = owner_record[1] || owner_record[2] rescue nil
            street1 = owner_record[3] rescue nil
            street2 = owner_record[4] rescue nil
            county  = owner_record[9] rescue nil
            city    = owner_record[5] rescue nil
            state   = owner_record[6] rescue nil
            postal  = owner_record[8] rescue nil
            region  = owner_record[15] rescue nil         
            
            owner = {
              :type => type,
              :name => name,
              :street1 => street1,
              :street2 => street2,
              :county => county,
              :city => city,
              :state => state,
              :postal => postal,
              :region => region
            }
            
            owners << owner
            
          end
          
          source_data = {
              :make => make,
              :model_name => model_name,
              :serial => serial,
              :registration => registration,
              :year => year,
              :location => location,
              :owners => owners
          } 

       end
       
       return source_data
        
    end
    
    # return a hash of the source record
    def map
        
        # parse source data 
        @source_record = parse_input

        # validate the source record
        return Hash.new if !source_valid?

        # create sha1 from URL
        token = Digest::SHA1.hexdigest(
            @source_record[:make] + 
            @source_record[:model_name] + 
            @source_record[:serial]
        )
        
        # is there a translation record?
        translation = Translation.where(:token => token, 
                                        :source_id => source_id).first
        
        # if not, is there a classification rule?
        if translation.blank?

            # convert source data hash to a classifier
            classifier_data = {
                :source_model => @source_record[:model_name],
                :source_make => @source_record[:make],
                :source_id => source_id,
                :serial => @source_record[:serial]
            }

            # look for existing classifier, or make a new one
            rule = Classifier.find_from_source_record(classifier_data)
      
            # create rule
            rule ||= Classifier.create(classifier_data)

            # if rule is empty, then exit
            return Hash.new if rule.blank? || !rule.filled?

            # find a target record if one exists
            target = rule.match_target_by_serial

            # otherwise make a new target record
            target = rule.create_target if target.blank?
             
            # create the translation for future use
            translation = Translation.create(
                :token => token, 
                :source_id => source_id, 
                :target_id => target.id) if !target.blank?

        end
        
        # add target id to hash
        if !translation.blank?
            target_id_hash = {:target_id => translation.target_id }
            @source_record.merge! target_id_hash
        end

        # send hash to reducer 
        return @source_record
        
    end
    
end
