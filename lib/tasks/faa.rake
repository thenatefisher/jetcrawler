require "digest/sha1"

namespace :faa do

    task :update => :environment do

        open(Jetcrawler::Application.config.faa_latest + "/MASTER.txt") do |infile|
            infile.read.each_line do |row|

                aircraft     = row.split(",")

                registration = "N"+aircraft[0].strip
                serial       = aircraft[1].strip
                af_mfg_code  = aircraft[2].strip
                eng_mfg_code = aircraft[3].strip
                year         = aircraft[4].strip.to_i
                eng_type     = aircraft[19].strip.to_i
                af_type      = aircraft[18].strip.to_i
                cert_type    = aircraft[17].strip.to_i

                eng_count    = 0
                af_model     = nil
                af_make      = nil
                eng_make     = nil
                eng_model    = nil

                if (cert_type == 1) && # active certifications
                    (year > 1980)   && 
                    (eng_type > 1)  && # turboprops
                    (eng_type < 6)  && # and jets
                    (af_type > 3)   && # 12,500 lbs +
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

                        # create translation rule parameters
                        ex_record_details = {
                            :serial => serial,
                            :source_id => 1, 
                            :ex_model => af_model, 
                            :ex_make => af_make
                        }

                        # look for translation rule
                        rule = Rule::Get_rule(ex_record_details)
                        
                        # create a blank rule if one does not yet exist
                        # otherwise, update the suggested prefix field bsaed on an AND 
                        # of this aircraft serial number and previous suggestion
                        rule = Rule.create(ex_record_details.slice(:ex_modal, :ex_make, :source_id)) if !rule
                        next if rule.match(serial).nil? 
                        
                        # use it to look for a specific airframe
                        a =	rule.match(serial)
                        
                        # if no airframes exist in jetcrawler db, create one
                        a ||= Airframe.create(:serial_iterator => rule.serial_integer(serial), :make => rule.jd_make, :model_name => rule.jd_model)
                    
                        # create the translation for future use
                        t = Translation.create(:ex_id => ex_id, :source_id => 1, :jd_id => a.id) if a

                    end

                    # find aircraft from jetcrawler db
                    a ||= Airframe.find(t.jd_id) if t.jd_id.present?

                    if a
                        # found the definitive airframe; update aircraft
                        a.serial       = serial if !a.serial
                        a.make         = af_make if !a.make
                        a.model        = af_model if !a.model_name
                        a.year         = year if !a.year
                        a.registration = registration
                        a.save

                    end

                end

            end

        end

    end

end
