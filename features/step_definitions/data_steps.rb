Given /^I have a data type with name "([^\"]*)", description "([^\"]*)", for the department "([^\"]*)", with the following data fields$/ do |data_type_name, description, department, table|

  data_type = DataType.create!(:name => data_type_name, :description => description, :department_id => Department.find_by_name(department).id)

  table.hashes.each do |row|
      DataField.create!(:data_type_id => data_type.id,
                        :name => row[:name],
                        :display_type => row[:display_type],
                        :values => row[:values])
    end
end

