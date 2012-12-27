class AmstatMap < JetCrawlerMap
        
    # parse html input, return type Target
    def parse_input

        registration      = @item[4].gsub(/"/,'').strip
        serial            = @item[3].gsub(/"/,'').strip
        make              = @item[1].gsub(/"/,'').strip      
        year              = @item[5].gsub(/"/,'').strip.to_i
        model_name 	      = @item[2].gsub(/"/,'').strip 
        ttaf		      = @item[105].gsub(/"/,'').strip.to_i rescue nil
        
        # inject noise into AMSTAT TT data
        ttaf = (ttaf*(1+(5+rand(5)).to_f/100)).to_i if ttaf
            
        source_data = {
            :make =>make,
            :model_name => model_name,
            :serial => serial,
            :registration => registration,
            :year => year,
            :ttaf => ttaf,
            :tcaf => nil,
            :price => nil,   
            :location => nil,
            :equipment => nil,
            :avionics => nil,  
            :description => nil, 
            :interior => nil, 
            :exterior => nil, 
            :inspection => nil, 
            :owners => [],      
            :seller => nil,
            :engines => [],
            :image_urls => []
        } 
        
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
