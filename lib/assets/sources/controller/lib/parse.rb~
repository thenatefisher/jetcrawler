require 'nokogiri'
require 'open-uri'

module ControllerParse
 
    def ControllerParse.parse(input)
            
        html = open(input)
        doc = Nokogiri::HTML(html)
        
        page_details = Hash.new
        doc.css("#tblSpecs tr").each do |tr|
            if tr.css("td").count == 2
                param = tr.css("td")[0].content.gsub(/[^a-zA-Z0-9]/, "")
                value = tr.css("td")[1].content.gsub(/[^a-zA-Z0-9\- ]/, "")
                page_details[param.to_sym] = value if !param.blank?
            end
        end
        
        # parse document into a hash
        year = page_details[:Year]
        make = page_details[:Manufacturer]
        model_name = page_details[:Model]

        registration = page_details[:RegistrationNumber]
        serial = page_details[:SerialNumber]

        price = page_details[:Price].gsub!(/[^\d]/, "") rescue nil
        ttaf = page_details[:TotalTime].gsub!(/[^\d]/, "") rescue nil
        location = page_details[:Location]
        
        source_data = {
            :make =>make,
            :model_name => model_name,
            :serial => serial,
            :registration => registration,
            :year => year,
            :ttaf => ttaf,
            :tcaf => nil,
            :price => price,   
            :location => location,
            :equipment => {},
            :avionics => {},  
            :description => nil, 
            :interior => nil, 
            :exterior => nil, 
            :inspection => nil, 
            :owner => {},      
            :seller => {},
            :engines => {},
            :image_urls => {}
        } 
        
        
           
    end

end

