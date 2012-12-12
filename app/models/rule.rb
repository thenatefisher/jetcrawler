class Rule < ActiveRecord::Base
    attr_accessible :db, :ex_make, :ex_model, :jd_make, :jd_model, :source_id, :suggested_prefix, :min_sn, :max_sn

    before_create :init
    validate :validate_window

    def serial_integer(serial)
        Rule::Serial_integer(serial, self.serial_prefix)
    end

    def self.Serial_integer(serial, prefix=nil)

        return false if serial.nil?

        # create distinct serial number INTEGER from aircraft sn string
        # remove prefix, letters and zero padding from serial
        sn = serial
        sn = sn.gsub(/^(#{prefix})/, '') if prefix
        sn = sn.gsub(/[^\d]/,'').to_i

    end

    def self.Get_rule(params)

         r = Rule.find(:first, :conditions => ["jd_make IS NOT NULL 
                                          AND jd_model IS NOT NULL
                                          AND ex_model = ?
                                          AND ex_make = ?
                                          AND source_id = ?",
                                          params[:ex_model], 
                                          params[:ex_make],
                                          params[:source_id]])
        
         if r 

           sn_int = Rule::Serial_integer(params[:serial], r.serial_prefix) 
           
           r = Rule.find(:first, :conditions => ["jd_make IS NOT NULL 
                                          AND jd_model IS NOT NULL
                                          AND ex_model = ?
                                          AND ex_make = ?
                                          AND source_id = ?
                                          AND min_sn < ?
                                          AND max_sn > ?",
                                          params[:ex_model], 
                                          params[:ex_make],
                                          params[:source_id],
                                          sn_int,
                                          sn_int])
        end

        # if a rule matches, tune the rule sn prefix suggestion
        r.update_prefix_suggestion(params[:serial]) if r

        return r

    end

    def match(serial)
        Airframe.find(:first, :conditions => ["make = ? AND model_name = ? AND serial_iterator = ?", self.jd_make, self.jd_model, self.serial_integer(serial)])
    end

    def update_prefix_suggestion(serial)

        suggestion = ""
        serial.split(//).each_with_index do |a, i|		    
            break if !suggested_prefix[i] || a != suggested_prefix[i]
            suggestion << a
        end
        suggested_prefix = suggestion
        self.save

    end

    def validate_window

        # resets
        self.max_sn = 999999 if self.max_sn.nil?
        self.min_sn = 0 if self.min_sn.nil? || self.min_sn < 0
        self.max_sn = 0 if self.max_sn < 0

        # can't reverse the max and min window
        self.min_sn = self.max_sn if self.min_sn > self.max_sn
        self.max_sn = self.min_sn if self.max_sn < self.min_sn

        # can't intersect with another rule of the same make/model type

        if !Rule.find(:all, :conditions => ["ex_model = ?
                                          AND ex_make = ?
                                          AND source_id = ?
                                          AND max_sn >= ? AND min_sn <= ?",
                                          self.ex_model, 
                                          self.ex_make,
                                          self.source_id, 
                                          self.min_sn, self.min_sn]).empty?

            errors.add(:min_sn, "minimum limit is within another rule's range")
        end

        if !Rule.find(:all, :conditions => ["ex_model = ?
                                          AND ex_make = ?
                                          AND source_id = ?
                                          AND max_sn >= ? AND min_sn <= ?",
                                          self.ex_model, 
                                          self.ex_make,
                                          self.source_id, 
                                          self.max_sn, self.max_sn]).empty?

            errors.add(:max_sn, "maximum limit is within another rule's range")
        end
    end

    def init
        self.active = false
        self.min_sn = 0 if self.min_sn.nil?
        self.max_sn = 999999 if self.max_sn.nil?
    end

end
