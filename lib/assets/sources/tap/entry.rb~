require 'nokogiri'

class TapEntry < JetCrawlerEntry

    def create_collection

        output = Array.new()

        # only turbo props and jets
        cookie_data = `curl -I "http://www.trade-a-plane.com" 2> /dev/null`
        cookie = cookie_data.match(/SESSION_ID=[^;]*/)[0]
        cookie += "; ACTIVESUB=0;"
        agent       = "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:17.0) Gecko/20100101 Firefox/17.0"
        
        for cat in ["Jet", "TurboProp"]
            
            index_url   = "http://www.trade-a-plane.com/search?s-type=aircraft&category=#{cat}&s-seq=1&s-lvl=3&s-view=simple&s-page_size=100"

            i = 1
            begin
            
                index_page_url = (i > 1) ? index_url + "&s-page=#{i}" : index_url
                i += 1
                
                response = `curl -H "Accept-Language: en-US,en;q=0.5" -H "Accept-Encoding: gzip, deflate" -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" --cookie "#{cookie}" -A "#{agent}" --compressed "#{index_page_url}" 2> /dev/null`

                doc = Nokogiri::HTML(response)

                items_on_page = 0
                
                doc.css("#results td:nth-child(3) a").each do |row|
                    items_on_page += 1
                    output << "http://www.trade-a-plane.com" + row.attr("href") rescue nil
                end

            end while (items_on_page > 0)
        
        end
        
        # unique the output list
        output.uniq!

        # record latest db date
        self.latest_database_touch

        return output
        
    end

end

