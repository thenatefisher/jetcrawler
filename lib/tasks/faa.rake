require "digest/sha1"

namespace :faa do

    task :update => :environment do

        open(Jetcrawler::Application.config.faa_latest + "/MASTER.txt") do |infile|
            infile.read.each_line do |row|

                aircraft = row.split(",")

                registration      = "N"+aircraft[0].strip
                serial            = aircraft[1].strip
                af_mfg_code       = aircraft[2].strip      
                eng_mfg_code      = aircraft[3].strip
                year              = aircraft[4].strip.to_i
                eng_type          = aircraft[19].strip.to_i
                af_type           = aircraft[18].strip.to_i
                cert_type         = aircraft[17].strip.to_i

                eng_count         = 0
                af_model          = nil
                af_make           = nil
                eng_make          = nil
                eng_model         = nil

                if (cert_type == 1) &&
                    (year > 1980) && 
                    (eng_type > 1) && 
                    (eng_type < 6) && 
                    (af_type > 3) && 
                    (af_type < 7)

                    acft_ref = open(Jetcrawler::Application.config.faa_latest + "/ACFTREF.txt")
                    .grep(/#{af_mfg_code}/i).first

                    if acft_ref 
                        acft_ref = acft_ref.split(",")
                        ref_code = acft_ref[0].strip
                        if (ref_code == af_mfg_code)
                            af_make  = acft_ref[1].strip
                            af_model = acft_ref[2].strip
                            eng_count  = acft_ref[7].to_i
                        end
                    end

                    eng_ref = open(Jetcrawler::Application.config.faa_latest + "/ENGINE.txt")
                    .grep(/#{eng_mfg_code}/i).first

                    if eng_ref 
                        eng_ref = eng_ref.split(",")
                        ref_code = eng_ref[0].strip
                        if (ref_code == eng_mfg_code)
                            eng_make = eng_ref[1].strip
                            eng_model = eng_ref[2].strip
                        end
                    end

                    # create hash of make model and serial
                    ex_id = Digest::SHA1.hexdigest af_make + af_model + serial

                    # create airframe record placeholder
                    a = Airframe.new

                    # find translation table entry
                    t = Translation.where(:ex_id => ex_id, :source_id => 1).first

                    # otherwise, try to create a translation	
                    if t.nil?

                        # look for translation rule
                        r = Rule.where(:source_id => 1, :ex_model => af_model, :ex_make => af_make).first
                        if !r
                            r = Rule.create(:suggested_prefix => serial, :ex_make => af_make, :ex_model => af_model, :source_id => 1)
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
                            t = Translation.create(:ex_id => ex_id, :source_id => 1, :jd_id => a.id) if a
                        else
                            next
                        end

                    end

                    # find aircraft from jetcrawler db
                    a = Airframe.find(t.jd_id) if t.jd_id.present?

                    if a

                        # update airframe
                        #  new ownership
                        #  airframe details
                        a.serial = serial if !a.serial
                        a.make = af_make if !a.make
                        a.model = af_model if !a.model_name
                        a.year = year if !a.year
                        a.registration = registration if !a.registration
                        a.save

                    end

                end

            end

        end

    end

end
