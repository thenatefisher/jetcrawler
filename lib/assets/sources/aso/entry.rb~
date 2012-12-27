require 'nokogiri'
require 'uri'

class AsoEntry < JetCrawlerEntry

    def create_collection

        output = Array.new()
        
        # only turbo props and jets
        index_url  = "http://www.aso.com/listings/AircraftListings.aspx?searchId=2179883"
        first_page  = `curl "#{index_url}" 2> /dev/null`
        
        doc = Nokogiri::HTML(first_page)
        doc.css(".photoListingsDescription").each do |item|
            output << "http://www.aso.com/listings/" + item.attr("href")
        end
        
    
        while next_page_available(doc)
            
            viewstate = URI.escape(doc.at_css("#__VIEWSTATE").attr("value"), "/+$")
            et = URI.escape("ctl00$ContentPlaceHolder1$SearchResultsPhotoGrid$DataPagerTop$ctl00$btnNext", "$")
            
            response = `curl -H "Accept-Language: en-US,en;q=0.5" -H "Accept-Encoding: gzip, deflate" -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" -A "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:17.0) Gecko/20100101 Firefox/17.0" --compressed -d "__EVENTTARGET=#{et}&__VIEWSTATE=#{viewstate}" "#{index_url}" 2> /dev/null`
            
            doc = Nokogiri::HTML(response)          
            
            doc.css(".photoListingsDescription").each do |item|
                output << "http://www.aso.com/listings/" + item.attr("href")
            end

        end 
        
        # unique the output list
        output.uniq!

        # record latest db date
        self.latest_database_touch
          
        return output
        
    end
    
    def next_page_available(doc)
    
        doc.at_css("#ctl00_ContentPlaceHolder1_SearchResultsPhotoGrid_DataPagerTop_ctl00_btnNext").attr("disabled") != "disabled"    
        
    end
    
end

