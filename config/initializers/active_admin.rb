ActiveAdmin.setup do |config|
  # Site Title
  config.site_title = "Prairie Paws Pet Supplies"

  #  User Authentication
  config.authentication_method = :authenticate_admin_user!

  # Current User
  config.current_user_method = :current_admin_user

  #  Logging Out
  config.logout_link_path = :destroy_admin_user_session_path

  # Admin Comments
  config.comments = false

  # Attribute Filters
  config.filter_attributes = [ :encrypted_password, :password, :password_confirmation ]

  # Localize Date/Time Format
  config.localize_format = :long

  #  Menu System (Top-Right Admin Email Profile Link + Logout)
  config.namespace :admin do |admin|
    admin.build_menu :utility_navigation do |menu|
      menu.add id: "current_user",
               label: proc { current_admin_user&.email },
               url: proc { profile_admin_admin_users_path },
               if: proc { current_admin_user.present? },
               priority: 10
      admin.add_logout_button_to_menu menu
    end
  end
end