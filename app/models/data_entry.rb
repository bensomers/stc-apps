class DataEntry < ActiveRecord::Base
  belongs_to :data_object
  
  # Write DataEntry content as a string with the following delimiters:
  #   Double semicolon between each datafield
  #   Double colon between the id of the datafield and the information it holds
  #   For datafields that themselves contain hashes:
  #     semicolons between each pair in the hash
  #     colons between keys and their associated values
  # ; and : in supplied content are escaped as **semicolon** and **colon**
  def write_content(fields)
    content = ""
    fields.each_pair do |key, value|
      if value.class == HashWithIndifferentAccess
        content << key.to_s + "::"
        value.each_pair do |k,v|
          content << k.to_s + ":"
          content << v.to_s.gsub(";","**semicolon**").gsub(":","**colon**") + ";"
        end
        content.chomp!(";")          #strip off the final semicolon
        content << ";;"        
      else
        content << key.to_s + "::"
        content << value.to_s.gsub(";","**semicolon**").gsub(":","**colon**") + ";;"
      end
    end
    return self.content = content.chomp!(';;') #strip last final double semicolon
  end
  
  #Returns the entry's content after escaping out : and ; characters
  def self.escape_chars(string)
    string.gsub(';', '**semicolon**').gsub(':', '**colon**')
  end
  
### Virtual attributes ###
  # Returns all the data fields referenced by a given data entry
  def data_fields
    self.content.split(';;').map{|str| str.split('::')}.map{|a| a.first}
  end
  
  # Returns the data fields and user content in a set of [field, content] arrays
  def data_fields_with_contents
    self.content.split(';;').map{|str| str.split('::')}.map do |a|
      [a.first, a.second.gsub('**semicolon**',';').gsub('**colon**',':')]
    end
  end

end
