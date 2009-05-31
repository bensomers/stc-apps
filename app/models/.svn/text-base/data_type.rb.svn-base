class DataType < ActiveRecord::Base
  
  has_many :data_objects, :dependent => :destroy
  belongs_to :department
  
  def used_fields
    #returns an array of arrays, each one being a [fieldname, value] pair
    DataType.field_names.reject {|name| self[name].blank?}.map{|name| [name, self[name]]}
  end
  
  def self.field_names
    field_names = DataType.column_names - ['id', 'name', 'created_at', 'department_id']
  end
  
  def self.string_fields
    DataType.column_names.select{|c| c.match(/^s[0-9]/)}
  end
  
  def self.integer_fields
    DataType.column_names.select{|c| c.match(/^i[0-9]/)}    
  end
  
  def self.boolean_fields
    DataType.column_names.select{|c| c.match(/^b[0-9]/)}    
  end
  
  def self.float_fields
    DataType.column_names.select{|c| c.match(/^f[0-9]/)}    
  end
  
  #not currently in use - slated for removal
  def formatted_field_names
    fields = Array.new(self.field_names)
    fields.each do |field|
      field.sub!(/s[0-9]+/) {|inum| "string #{inum.match(/[0-9]+/)} "}
      field.sub!(/i[0-9]+/) {|inum| "integer #{inum.match(/[0-9]+/)} "}
      field.sub!(/b[0-9]+/) {|inum| "boolean #{inum.match(/[0-9]+/)} "}
      field.sub!(/f[0-9]+/) {|inum| "float #{inum.match(/[0-9]+/)} "}
    end
    fields
  end
  
end
