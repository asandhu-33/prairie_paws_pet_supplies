class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_cart, :cart_item_count

  protected

  def configure_permitted_parameters
    extra_keys = %i[name address city postal_code province_id]
    devise_parameter_sanitizer.permit(:sign_up, keys: extra_keys)
    devise_parameter_sanitizer.permit(:account_update, keys: extra_keys)
  end

  def after_sign_out_path_for(resource_or_scope)
    if resource_or_scope.to_s == "admin_user" || resource_or_scope.is_a?(AdminUser)
      root_path
    else
      super
    end
  end

  private

  # Returns the session cart hash
  def current_cart
    session[:cart] ||= {}
  end

  # Returns total number of individual items in the session cart
  def cart_item_count
    current_cart.values.sum(&:to_i)
  end
end