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

                    # create translation rule parameters
                    ex_record_details = {
                        :serial => serial,
                        :source_id => 1, 
                        :ex_model => af_model, 
                        :ex_make => af_make
                    }
                    
                    # find or create the definitive airframe record
                    a = Airframe::Find_or_create_by_mmss(ex_record_details)

                    if a
                        a.year         = year if !a.year
                        a.registration = registration
                        a.save
                    end

                end

            end

        end

    end

end
