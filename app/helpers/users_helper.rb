module UsersHelper
  def update_user_select_and_hidden_ids_field(page)
    page.select('div.ids_for_user_chooser').each do |value|
      page.replace_html value, (hidden_field_tag 'selected_ids', @selected_users.collect(&:id).join(','))
    end
    page.replace_html 'selected_users', :partial => '/users/user_select'
  end
end
