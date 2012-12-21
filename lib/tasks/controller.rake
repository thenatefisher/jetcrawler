require 'digest/sha1'
require 'nokogiri'
require_relative 'cdc_helper'

namespace :update do

    task :cdc_index => :environment do

        index_url = "http://www.controller.com/list/list.aspx?Pref=1&ETID=1&setype=1&Mdltxt=%25&SO=15&mdlx=contains&bcatid=13"
        i = 0
        current_page = 1

        begin

            doc = Nokogiri::HTML(fetch_cdc(index_url+"&pg=#{(i+1)}"))

            i=i+1 
            current_page = doc.css("#ctl00_ctl09_lblText").first.content.match(/(\d+) of \d+/)[1]

            doc.css(".onelinelistrow, .onelinelistaltrow").each do |row|
                link = "http://www.controller.com" + row.css("td:nth-child(2) a").attr("href").content

                page_details = Hash.new
                doc = Nokogiri::HTML(open(link))

                doc.css("#tblSpecs tr").each do |tr|
                    if tr.css("td").count == 2
                        param = tr.css("td")[0].content.gsub(/[^a-zA-Z0-9]/, "")
                        value = tr.css("td")[1].content.gsub(/[^a-zA-Z0-9\- ]/, "")
                        page_details[param.to_sym] = value if !param.blank?
                    end
                end

                # fix total time to be only digits
                page_details[:TotalTime].gsub!(/[^\d]/, "") if page_details[:TotalTime]

                puts "#{page_details[:Manufacturer]} #{page_details[:SerialNumber]} - #{page_details[:TotalTime]}\n"
                next
                # create translation rule parameters
                ex_record_details = {
                    :serial => serial,
                    :source_id => 3, 
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

        end while (current_page == i.to_s)

    end

end


