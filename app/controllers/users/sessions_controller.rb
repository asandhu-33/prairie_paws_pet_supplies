class Users::SessionsController < Devise::SessionsController
  def create
    email = params.dig(:user, :email).to_s.strip.downcase
    password = params.dig(:user, :password).to_s

    admin = AdminUser.find_by(email: email)

    if admin&.valid_password?(password)
      sign_in(:admin_user, admin)
      redirect_to admin_root_path, notice: "Signed in as administrator."
    else
      super
    end
  end
end