class FaaMap < JetCrawlerMap
        
    # parse html input, return type Target
    def parse_input
        
        latest_dir = File.expand_path(File.join(Jetcrawler::Application.config.registers, "faa", "latest"))
        faa_master  = File.expand_path(File.join(latest_dir, "MASTER.txt"))
        faa_dereg   = File.expand_path(File.join(latest_dir, "DEREG.txt"))
        faa_engine  = File.expand_path(File.join(latest_dir, "ENGINE.txt"))
        faa_acftref = File.expand_path(File.join(latest_dir, "ACFTREF.txt"))
                
        registration = "N"+@item[0].strip
        serial       = @item[1].strip
        af_mfg_code  = @item[2].strip
        eng_mfg_code = @item[3].strip
        year         = @item[4].strip.to_i
        eng_type     = @item[19].strip.to_i
        af_type      = @item[18].strip.to_i
        cert_type    = @item[17].strip.to_i

        eng_count    = 0
        af_model     = nil
        af_make      = nil
        eng_make     = nil
        eng_model    = nil
        
        source_data = Hash.new
        
        if (cert_type == 1) && # active certifications
            (year > 1980)   && 
            (eng_type > 1)  && # turboprops
            (eng_type < 6)  && # and jets
            (af_type > 3)   && # 12,500 lbs +
            (af_type < 7)

            acft_ref = open(faa_acftref).grep(/#{af_mfg_code}/i).first

            if acft_ref 
                acft_ref = acft_ref.split(",")
                ref_code = acft_ref[0].strip
                if (ref_code == af_mfg_code)
                    make  = acft_ref[1].strip
                    model_name = acft_ref[2].strip
                    eng_count  = acft_ref[7].to_i
                end
            end

            eng_ref = open(faa_engine).grep(/#{eng_mfg_code}/i).first

            if eng_ref 
                eng_ref = eng_ref.split(",")
                ref_code = eng_ref[0].strip
                if (ref_code == eng_mfg_code)
                    eng_make = eng_ref[1].strip
                    eng_model = eng_ref[2].strip
                end
            end
            
            engines = Array.new
            eng_count.times do |i|
            
              engine = {
                :make => eng_make,
                :model_name => eng_model
              }
              
              engines << engine
            
            end
                  
            owners = Array.new

            type    = @item[5].strip.to_i
            type    = 2 if type > 1
            name    = @item[6].strip
            street1 = @item[7].strip
            street2 = @item[8].strip
            county  = @item[14].strip
            city    = @item[9].strip
            state   = @item[10].strip
            postal  = @item[11].strip
            region  = @item[12].strip     
            
            primary_owner = {
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
            
            owners << primary_owner
            owners << {:name => @item[24].strip} if !@item[24].strip.blank?
            owners << {:name => @item[25].strip} if !@item[25].strip.blank?
            owners << {:name => @item[26].strip} if !@item[26].strip.blank?
            owners << {:name => @item[27].strip} if !@item[27].strip.blank?
            owners << {:name => @item[28].strip} if !@item[28].strip.blank?
                      
            source_data = {
                :make =>make,
                :model_name => model_name,
                :serial => serial,
                :registration => registration,
                :year => year,
                :owners => owners,
                :engines => engines
            } 
            
        else
        
            return {}
            
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
