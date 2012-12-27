require 'nokogiri'

module TapParse

    def TapParse.parse(input)
        
        begin
            
            # get the session id we need for a page request
            cookie_data =  `curl -I "http://www.trade-a-plane.com" 2> /dev/null`
            cookie      =  cookie_data.match(/SESSION_ID=[^;]*/)[0]
            cookie      += "; ACTIVESUB=0;"
            agent       =  "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:17.0) Gecko/20100101 Firefox/17.0"
                       
            # create curl command
            command =   "curl"
            command +=  " -H \"Accept-Language: en-US,en;q=0.5\""
            command +=  " -H \"Accept-Encoding: gzip, deflate\"" 
            command +=  " -H \"Content-Type: application/x-www-form-urlencoded; charset=UTF-8\""
            command +=  " -H \"User-Agent: #{agent}\""
            command +=  " --cookie \"#{cookie}\""            
            command +=  " --compressed \"#{input}\""
            command +=  " 2> /dev/null"
            
            # fetch html
            html = `#{command}`
            doc = Nokogiri::HTML(html)
            
            # parse document into a hash
            year = doc.css("#summary ul li").first.content.gsub!(/[^\d]/, "") rescue nil
            make = doc.at_css("#summary span[itemprop='manufacturer'] span[itemprop='name']").content rescue nil
            model_name = doc.at_css("#summary span[itemprop='model']").content rescue nil
            price = doc.at_css("#summary span[itemprop='price']").content.gsub!(/[^\d]/, "") rescue nil    
            serial = doc.at_css("#summary span[itemprop='offers'] li:nth-child(4)").content.match(/Serial Number:(.*)/)[1] rescue nil
            registration = doc.at_css("#summary span[itemprop='offers'] li:nth-child(5)").content.match(/Registration Number:(.*)/)[1] rescue nil
            ttaf = doc.at_css("#summary span[itemprop='offers'] li:nth-child(6)").content.match(/Airframe Total Time:(.*)/)[1] rescue nil
            tcaf = nil
            location = nil
            
            # return a hash      
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

