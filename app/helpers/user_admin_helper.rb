module UserAdminHelper
  def roleUsers(role)
    users = User.find_by_sql(["SELECT DISTINCT users.login, users.id FROM users JOIN roles_users JOIN roles WHERE
                               users.id = roles_users.user_id AND roles_users.role_id = ? ORDER BY login ASC", role.id])
  end
  
  def editNewTitleHelper(obj)
    obj.id.nil? ? "New" : "Edit"
  end

  def indentRole(role)
    role_display_string = ""
    role.name.count("/").times { role_display_string += '&nbsp;' * 6}
    if role.name.count("/") == 0
      # role_display_string = "<br />"
    end
    role_display_string
  end
  
end
