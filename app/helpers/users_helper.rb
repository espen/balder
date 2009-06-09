module UsersHelper
  def has_permission?(permissions = [])
    return current_user && current_user.has_permission?(permissions)
  end
  
  def has_role?(roles = [])
    return current_user && current_user.in_role?(roles)
  end
end
