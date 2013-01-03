require_relative "lib/parse"

class AsoMap < JetCrawlerMap
    include AsoParse
        
    # parse html input, return type Target
    def parse_input
    
        # extract all the goodness from the aso aircraft page
        parsed_data = AsoParse::parse(@item) if !@item.blank?
        parsed_data ||= Hash.new
        
    end
    
    # return a hash of the source record
    def map
        
        # parse source data 
        @source_record = parse_input
        
        # validate the source record
        return Hash.new if !source_valid?

        # create sha1 from URL
        #token = Digest::SHA1.hexdigest(@item)
        
        token = @item
        token = token[-250..-1] if token.length > 250

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
