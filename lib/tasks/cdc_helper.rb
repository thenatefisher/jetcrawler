require 'uri' 
require 'open-uri'

def decode_string(str) 
    return URI.unescape str
end

def fetch_cdc(url)

    doc = `curl --user-agent "Mozilla/5.0 (X11; Linux i686) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.47 Safari/536.11" "#{url}"`

    begin 
        table   = doc.match(/table = \"(.*)\"/)[1]
        prefix  = doc.match(/document\.forms\[0\]\.elements\[1\]\.value=\"([^:]*)/)[1]
        c       = doc.match(/c = (.*)$/)[1]
        slt     = doc.match(/slt = \"(.*)\"/)[1]
        s1      = doc.match(/s1 = '(.*)'/)[1]
        s2      = doc.match(/s2 = '(.*)'/)[1]
        n       = 4
        clg     = ""
    rescue
        return doc
    end

    start = s1.ord
    cend = s2.ord
    arr = Array.new()
    m = ((cend - start) + 1)**n

    for i in 0..(n-1)
        arr[i] = s1
    end

  
    for i in 0..(m - 2)
        
        (n-1).downto(0) do |j|
            t = arr[j].ord
            t = t+1
            arr[j] = t.chr("UTF-8")
            if (arr[j].ord <= cend)
                break
            else
                arr[j] = s1
            end
        end
        
        chlg = arr.join('')
        str = chlg + slt
        crc = -1
        
        for k in 0..(str.length - 1)
            index = crc ^ str[k].ord if str[k]
            index ||= -1
            si = ((index & 0x000000FF) * 9)
            t_hex_s = "0x" + table[si..(si+8)]
            thex = (t_hex_s).hex
            crc = (crc >> 8) ^ thex
            crc = (crc > 2**31) ? crc - 2**32 : crc
            crc = (crc < -2147483648) ? sprintf("%b", ~((crc.abs)))[3..-1].to_i(2)+1 : crc
        end
        
        crc = crc^(-1)
        crc = crc.abs
        if (crc == c.to_i)
            break
        end
        
    end

    # parameters for document request
    tS40436f_75 = decode_string(prefix + ":" + chlg.to_s + ":" + slt.to_s + ":" + crc.to_s)
    tS40436f_id = 3
    tS40436f_md = 1
    tS40436f_rf = "http://www.controller.com/"
    tS40436f_ct = 0
    tS40436f_pd = 0
    
    content = `curl -i -F "tS40436f_id=3&tS40436f_md=1&tS40436f_rf=0&tS40436f_ct=0&tS40436f_pd=0&tS40436f_75=#{tS40436f_75}" --user-agent "User-Agent:Mozilla/5.0 (X11; Linux i686) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.47 Safari/536.11" "#{url}"`
    
end


