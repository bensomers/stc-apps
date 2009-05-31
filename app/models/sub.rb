class Sub < ActiveRecord::Base
  belongs_to :user #requestor
  belongs_to :taker, :class_name => "User", :foreign_key => "new_user"
  
  belongs_to :shift
  
  attr_accessor :offer_to
  attr_accessor :email_to
  attr_accessor :bribe_flag
  
  validates_presence_of :start, :end, :shift_id, :user_id, :reason
  validate :bribe_range, :start_less_than_end, :sub_start_time_must_be_later

  named_scope :since, lambda { |time| {:conditions => ["end >= ?",time], :order => "start"} }
  named_scope :before, lambda {|time| {:conditions => ["start <= ?", time], :order => "start"}}
  named_scope :not_taken, :conditions => {:new_user => nil}
  named_scope :not_from, lambda{|user| {:conditions => ["user_id != ?", user.id]}}
  named_scope :target_blank, :conditions => {:target_ids => nil}
  
  def add_eligible(user)
    self.target_ids ||= ''
    self.target_ids << comma_wrap(user.id)
  end
  
  def long_display_for(some_user)
    s = [shift.location.long_name, " on ", shift.date.to_s(:just_date_long), " from ",
            self.start.to_s(:am_pm), " to ", self.end.to_s(:am_pm)].join
    some_user == user ? s : (user.name + ', ' + s)
  end
  
  def info
    s = "sub requested by %s, from %s to %s" % [user.name, start.to_s(:short_name), self.end.to_s(:am_pm)]
    s += ", at #{shift.location.short_name}"if shift
    s
  end
  
  def display_restrictions
    res = shift.location.all_unexpired_restrictions.reject {|r| r.max_subs.blank?}
    s = res.size.zero? ? "There's currently no restriction on the number of sub requests." : "<strong>Restrictions on public subs:</strong><br />"
    res.each do |r|
      c = user.subs.since(r.starts).before(r.expires_with_inf_considered).target_blank.count
      s += "Max <strong>#{r.max_subs}</strong> subs from #{r.starts.to_s(:short_name)} to #{r.end_time}.  You have used <strong>#{c}</strong><br />"
    end
    s += "Note: Public subs are those with 'Offer to' field left blank (sub request sent to everybody)." if res.size > 0
    s
  end
  
  def has_passed?
    self.end < Time.now
  end
  def taken?
    !new_user.nil?
  end
  
  def bribe_on?
    !(bribe_start.nil? || bribe_end.nil?)
  end
  
  def eligible?(user)
    #reload, just in case
    temp_s = (shift.reload rescue nil)
    if temp_s
      (temp_s.location.location_group.allow_sign_up?(user) and 
        (target_ids.nil? or target_ids.include?(comma_wrap(user.id))))
    else
      #delete that annoying illegal sub
      self.destroy
      nil
    end
  end
  
  def exceed_max?(add_public_sub = false)
    restrictions = shift.location.all_unexpired_restrictions.reject {|r| r.max_subs.blank?}
    restrictions.each do |r|      
      c = user.subs.since(r.starts).before(r.expires_with_inf_considered).target_blank.count
      if c==(max = r.max_subs) and add_public_sub
        errors.add(:offer_to, "can't be blank anymore - you can't make more public subs.  Please see restrictions.")
      elsif c > max
        errors.add_to_base("You have reached your maximum sub requests:<br />
                            You have: #{c}<br />
                            You are allowed: #{max} between #{r.starts.to_s(:short_name)} and #{r.end_time}")
      end
    end
    !errors.empty?
  end
  
  private
  
  def comma_wrap(num)
    ',' + num.to_s + ','    
  end
  
  def bribe_range
    errors.add(:bribe_end, "must not be earlier than sub end") if bribe_end and bribe_end < self.end
    errors.add(:bribe_start, "must not be later than sub start") if bribe_start and bribe_start > start
    errors.add_to_base("Invalid bribe time: same as requested sub time. Could be confusing!") if start==bribe_start and self.end==bribe_end
  end
  
  def start_less_than_end
    errors.add(:start, "must be earlier than end time") if (self.end <= start)
  end

  def sub_start_time_must_be_later
    errors.add(:start, "must be in the future") if (start <= Time.now)
  end
  
end