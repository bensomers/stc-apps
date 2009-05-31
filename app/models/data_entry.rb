class DataEntry < ActiveRecord::Base
  
  belongs_to :data_object
  
  def used_fields
    #returns the values contained in all fields that are neither nil nor empty
    self.field_names.reject {|name| self[name].blank?}.map{|name| [name, self[name]]}
  end
  
  def field_names
    field_names = DataEntry.column_names
    field_names.slice(2...-2) 
  end
    
  def empty?
    hash = self.attributes.clone
    hash.delete("updated_at")
    hash.delete("created_at")
    hash.delete("data_object_id")
    hash.delete("id")
    hash.values.compact.each do |v|
        return false unless v.blank?
    end
    true
  end
    
end
