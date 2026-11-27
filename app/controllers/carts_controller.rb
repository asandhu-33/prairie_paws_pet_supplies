class CartsController < ApplicationController
  before_action :require_customer_login
  before_action :set_product, only: %i[add update_item remove_item]

  def show
    @cart_items = []
    @subtotal = BigDecimal("0")

    current_cart.each do |product_id_str, raw_qty|
      product = Product.find_by(id: product_id_str.to_i)
      quantity = raw_qty.to_i

      # Skip deleted products or invalid quantities and clean up session
      if product.nil? || quantity <= 0
        current_cart.delete(product_id_str)
        next
      end

      line_total = product.price.to_d * quantity
      @subtotal += line_total
      @cart_items << {
        product: product,
        quantity: quantity,
        line_total: line_total
      }
    end
  end

  def add
    requested_qty = params[:quantity].to_i
    requested_qty = 1 if requested_qty <= 0

    max_qty = @product.stock.to_i
    if max_qty <= 0
      redirect_back fallback_location: product_path(@product), alert: "#{@product.name} is currently out of stock."
      return
    end

    key = @product.id.to_s
    existing_qty = current_cart[key].to_i
    new_qty = [existing_qty + requested_qty, max_qty].min

    current_cart[key] = new_qty

    if existing_qty + requested_qty > max_qty
      redirect_back fallback_location: product_path(@product),
                    notice: "Added #{@product.name} to cart (capped at available stock: #{max_qty})."
    else
      redirect_back fallback_location: product_path(@product),
                    notice: "Added #{requested_qty} × #{@product.name} to your cart."
    end
  end

  def update_item
    key = @product.id.to_s
    new_qty = params[:quantity].to_i

    if new_qty <= 0
      redirect_to cart_path, alert: "Quantity must be at least 1. Click Remove to delete #{@product.name} from your cart."
      return
    end

    max_qty = @product.stock.to_i
    if max_qty > 0 && new_qty > max_qty
      current_cart[key] = max_qty
      redirect_to cart_path, notice: "Quantity for #{@product.name} updated to maximum available stock (#{max_qty})."
    else
      current_cart[key] = new_qty
      redirect_to cart_path, notice: "Updated quantity for #{@product.name}."
    end
  end

  def remove_item
    current_cart.delete(@product.id.to_s)
    redirect_to cart_path, notice: "Removed #{@product.name} from your cart."
  end

  def clear
    session[:cart] = {}
    redirect_to cart_path, notice: "Your shopping cart has been cleared."
  end

  private

  def require_customer_login
    return if user_signed_in?

    redirect_to new_user_registration_path, alert: "Create an account to add item to cart."
  end

  def set_product
    @product = Product.find(params[:product_id])
  end
end