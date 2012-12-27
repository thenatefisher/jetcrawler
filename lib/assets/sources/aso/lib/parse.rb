require 'nokogiri'
require 'open-uri'

module AsoParse

    def AsoParse.parse(input)
            
        begin
        
            # fetch html
            html = open(input)
            # html = File.open(File.join(File.dirname(__FILE__), "..", "listing.html"))
            doc = Nokogiri::HTML(html)
            
            # parse document into a hash
            begin
            year_make_model = doc.css(".adSpecView-header-Descr").first.content
            year = year_make_model.match(/\d{4}/)[0] rescue nil
            make = year_make_model.match(/\d{4}\s([A-z]+)\s/)[1] rescue nil
            model_name = year_make_model.match(/\d{4}\s[A-z]+\s(.*$)/)[1] rescue nil
            rescue
            end
            
            begin
            reg_ser = doc.css(".adSpecView-header-RegSerialPrice")[0].css("span")
            registration = reg_ser[0].content[6..-1] rescue nil
            serial = reg_ser[1].content[9..-1] rescue nil
            rescue
            end
            
            begin
            price = doc.css(".adSpecView-header-RegSerialPrice")[1].css("span").first.content 
            price.gsub!(/[^\d]/, "")
            rescue 
            end
            
            begin
            ttaf_loc = doc.css(".adSpecView-header-RegSerialPrice")[2].css("span")
            ttaf = ttaf_loc[0].content.gsub(/[^\d]/, "") rescue nil
            location = ttaf_loc[1].content[10..-1].capitalize rescue nil
            rescue 
            end
            
            begin
            tcaf = doc.css(".adSpecView-engine-prop-maintenance-section-body").first.content
            tcaf = tcaf.match /Landings: ([0-9,]+)/ 
            tcaf = tcaf[1].gsub!(/[^\d]/, "") 
            rescue
            end
                    
            source_data = {
                :make =>make,
                :model_name => model_name,
                :serial => serial,
                :registration => registration,
                :year => year,
                :ttaf => ttaf,
                :tcaf => tcaf,
                :price => price,   
                :location => location,
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
            
        rescue
        
            return Hash.new
            
        end
  
    end

end

