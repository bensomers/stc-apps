class DataEntry < ActiveRecord::Base
  belongs_to :data_object
  
  #Returns the entry's content after escaping out : and ; characters
  def self.escape_chars(content)
    content.gsub(';', '**semicolon**').gsub(':', '**colon**')
  end
  
### Virtual attributes ###
  # Returns all the data fields referenced by a given data entry
  def data_fields
    self.content.split(';').map{|str| str.split(':')}.map{|a| a.first}
  end
  
  # Returns the data fields and user content in a set of [field, content] arrays
  def data_fields_with_contents
    self.content.split(';').map{|str| str.split(':')}.map do |a|
      [a.first, a.second.gsub('**semicolon**',';').gsub('**colon**',':')]
    end
  end
      
  
      
end
