AdminUser.find_or_create_by!(email: "admin11@gmail.com") do |admin|
  admin.password = "password"
  admin.password_confirmation = "password"
end
