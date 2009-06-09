class Notice < ActiveRecord::Base


  belongs_to  :author,
              :class_name => "User",
              :foreign_key => "author_id"

  validate :process_user_names, :content_not_blank

  attr_accessor :auth_text


  attr_writer :user_names
  def user_names
    @user_names || users(true).map(&:name).join(", ")
  end

  def auth_full_list
    result = []
    result.push "for users #{self.user_names}" unless self.users.empty?
    self.locations(true).each do |loc|
      result.push "for location #{loc.short_name}"
    end
    self.location_groups(true).each do |lg|
      result.push "for location group #{lg.short_name}"
    end
    result.join "<br/>"
  end

  def self.fetch_authorized_active(*object_array)
    relevant = []
    object_array.flatten!
    object_array.each do |object|
      relevant = relevant + Sticky.active(object)
    end
    relevant.uniq
  end

  def self.active(object)
    actives = Sticky.find_all_active
    relevant = []
    actives.each do |sticky|
      relevant << sticky if sticky.authorized?(object)
    end
    relevant
  end

  def authorized?(object)
    return nil unless object
    result = case object
      when LocationGroup: location_groups.include? object.id
      when Location: locations.include? object.id
      #when User: "for user #{object.name}" if users.include? object.id
      #comment: i think all the users should be displayed, otherwise a user might trash a sticky that was supposed to be addressed to more than one person -snl
      when User: users.include? object.id
      when Department: for_department_id == object.id
    end
    result
  end

  # old auth code that displayed only single item
  # def authorized?(object)
  #   result = case object
  #     when LocationGroup: "for location group #{object.short_name}" if location_groups.include? object.id
  #     when Location: "for location #{object.short_name}" if locations.include? object.id
  #     #when User: "for user #{object.name}" if users.include? object.id
  #     #comment: i think all the users should be displayed, otherwise a user might trash a sticky that was supposed to be addressed to more than one person -snl
  #     when User: "for users #{self.user_names}" if users.include? object.id
  #     when Department: "for department #{self.name}" if for_department_id == object.id
  #   end
  #    self.auth_text = result
  # end

  def process_user_names
    temp_users = []
    user_names.split(",").map(&:strip).each do |user_string|
      user = User.find_by_login(user_string) || User.find_by_name(user_string)
      if user
        temp_users << user.id
      else
        self.errors.add :user_names, "contains \'#{user_string}\'. Could not find user by that name or netid" unless user_string.blank?
      end
    end
    self.users = temp_users
  end

      def users(get_objects = false)
    array = auth_users.split.map &:to_i
    array = User.find(array) if get_objects
    array
  end
  def users=(array)
    array ||= []
    array.map! &:id if array.first.class == User
    self.auth_users = array.join " "
  end

  def self.make(hash = {})
    notice = new(hash)
    notice.start_time = Time.now
    notice
  end

  protected

  def content_not_blank
    self.errors.add :content, "cannot be blank" if content.blank?
  end


end

