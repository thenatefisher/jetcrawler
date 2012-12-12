require "digest/sha1"

namespace :amstat do

    task :update => :environment do

        infile = IO.read(Jetcrawler::Application.config.amstat_latest + "/MMS.csv").force_encoding("ISO-8859-1").encode("utf-8", replace: nil) 

        infile.each_line do |row|

            begin
                aircraft = row.split(";")
            rescue
                next
            end

            next if aircraft[1].nil? ||
                aircraft[2].nil? ||
                aircraft[3].nil? ||
                aircraft[4].nil? ||
                aircraft[5].nil? 

            registration      = aircraft[4].gsub(/"/,'').strip
            serial            = aircraft[3].gsub(/"/,'').strip
            af_make           = aircraft[1].gsub(/"/,'').strip      
            year              = aircraft[5].gsub(/"/,'').strip.to_i
            af_model 	      = aircraft[2].gsub(/"/,'').strip
            tt		          = aircraft[105].gsub(/"/,'').strip.to_i if aircraft[105].present?
            tc 		          = 0

            # inject noise into AMSTAT TT data
            tt = (tt*(1+(5+rand(5)).to_f/100)).to_i if tt

            # create hash of make model and serial
            ex_id = Digest::SHA1.hexdigest af_make + af_model + serial

            # create airframe record placeholder
            a = Airframe.new

            # find translation table entry
            t = Translation.where(:ex_id => ex_id, :source_id => 2).first

            # otherwise, try to create a translation	
            if t.nil?

                # look for translation rule
                r = Rule.where(:active => true, :source_id => 2, :ex_model => af_model, :ex_make => af_make).first
                if !r
                    r = Rule.create(:suggested_prefix => serial, :ex_make => af_make, :ex_model => af_model, :source_id => 2)
                    next
                else
                    suggestion = ""
                    serial.split(//).each_with_index do |a, i|		    
                        break if !r.suggested_prefix[i] || a != r.suggested_prefix[i]
                        suggestion << a
                    end
                    r.suggested_prefix = suggestion
                    r.save
                end

                # if suitable rule available
                if r && !r.jd_make.nil? && !r.jd_model.nil?
                    # remove prefix, letters and zero padding from serial
                    sn_iterator = serial
                    sn_iterator = sn_iterator.gsub(/^(#{r.serial_prefix})/, '') if r.serial_prefix
                    sn_iterator = sn_iterator.gsub(/[^\d]/,'').to_i
                    # use it to look for a specific airframe
                    a = Airframe.where(:serial_iterator => sn_iterator, :make => r.jd_make, :model_name => r.jd_model).first		  
                    # if no airframes exist in jetcraler db, create one
                    a ||= Airframe.create(:serial_iterator => sn_iterator, :make => r.jd_make, :model_name => r.jd_model)
                    # create the translation for future use
                    t = Translation.create(:ex_id => ex_id, :source_id => 2, :jd_id => a.id) if a
                else
                    next
                end

            end

            # find aircraft from jetcrawler db
            a = Airframe.find(t.jd_id) if t.jd_id.present?

            if a

                a.serial = serial if !a.serial
                a.make = af_make if !a.make
                a.model = af_model if !a.model_name
                a.year = year if !a.year
                a.registration = registration if !a.registration
                a.tt = tt if !a.tt	  
                a.tc = tc if !a.tc
                a.save

            end

        end

    end

end
