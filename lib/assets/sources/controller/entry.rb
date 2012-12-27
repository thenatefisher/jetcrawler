require 'nokogiri'
require_relative "lib/fetch"

class ControllerEntry < JetCrawlerEntry
    include FetchControllerIndex
    
    def create_collection

        output = Array.new()
        
        progress = ProgressBar.create(
          :title => "Building Index",
          :total => 30)  
          
        for cat in [3,8]
        
            # only turbo props and jets
            index_url  = "http://www.controller.com/list/list.aspx?Pref=1&ETID=1&setype=1&catid=#{cat}&bcatid=13"
            
            i = 0
            current_page = 1

            begin

                doc = Nokogiri::HTML(FetchControllerIndex::fetch_cdc(index_url+"&pg=#{(i+1)}"))

                i=i+1 
                current_page = doc.css("#ctl00_ctl09_lblText").first.content.match(/(\d+) of \d+/)[1]

                doc.css(".onelinelistrow, .onelinelistaltrow").each do |row|
                    output << "http://www.controller.com" + row.css("td:nth-child(2) a").attr("href").content rescue nil
                end
                
                progress.increment

            end while (current_page == i.to_s)
        
        end
        
        # unique the output list
        output.uniq!
        
        # record latest db date
        self.latest_database_touch
        
        progress.finish
                  
        return output
        
    end
    
    
end

