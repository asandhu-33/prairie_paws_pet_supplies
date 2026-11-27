class CheckoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_cart_not_empty

  def show
    @provinces = Province.order(:name)
    load_cart_items
    @selected_province = resolve_selected_province
    @invoice = Order.calculate_invoice(@subtotal, @selected_province)
    @customer_details = {
      name: current_user.name,
      address: current_user.address,
      city: current_user.city,
      postal_code: current_user.postal_code,
      province_id: @selected_province&.id
    }
  end

  def create
    @provinces = Province.order(:name)
    load_cart_items

    checkout_params = params.fetch(:checkout, {}).permit(:name, :address, :city, :postal_code, :province_id)
    province = Province.find_by(id: checkout_params[:province_id].presence || current_user.province_id)

    unless province
      @selected_province = nil
      @invoice = Order.calculate_invoice(@subtotal, nil)
      @customer_details = checkout_params.to_h.symbolize_keys
      flash.now[:alert] = "Please select your province to calculate taxes and complete checkout."
      render :show, status: :unprocessable_entity
      return
    end

    @selected_province = province
    @invoice = Order.calculate_invoice(@subtotal, province)
    @customer_details = {
      name: checkout_params[:name].presence || current_user.name,
      address: checkout_params[:address].presence || current_user.address,
      city: checkout_params[:city].presence || current_user.city,
      postal_code: checkout_params[:postal_code].presence || current_user.postal_code,
      province_id: province.id
    }

    ActiveRecord::Base.transaction do
      current_user.update!(
        name: @customer_details[:name],
        address: @customer_details[:address],
        city: @customer_details[:city],
        postal_code: @customer_details[:postal_code],
        province: province
      )

      order = current_user.orders.create!(
        province: province,
        order_number: generate_order_number,
        status: "Confirmed",
        shipping_address: @customer_details[:address],
        shipping_city: @customer_details[:city],
        shipping_postal_code: @customer_details[:postal_code],
        shipping_province: province.name,
        subtotal: @invoice[:subtotal],
        gst_rate: @invoice[:gst_rate],
        pst_rate: @invoice[:pst_rate],
        hst_rate: @invoice[:hst_rate],
        gst_amount: @invoice[:gst_amount],
        pst_amount: @invoice[:pst_amount],
        hst_amount: @invoice[:hst_amount],
        tax_total: @invoice[:tax_total],
        total: @invoice[:total]
      )

      @cart_items.each do |item|
        product = item[:product]
        qty = item[:quantity]

        order.order_items.create!(
          product: product,
          quantity: qty,
          unit_price: product.price
        )

        if product.stock.present?
          updated_stock = [product.stock - qty, 0].max
          product.update!(stock: updated_stock)
        end
      end

      session[:cart] = {}
      redirect_to root_path, notice: "Order ##{order.order_number} placed! Your address and order details have been saved."
    end
  rescue ActiveRecord::RecordInvalid => e
    @invoice = Order.calculate_invoice(@subtotal, @selected_province)
    flash.now[:alert] = "Could not complete checkout: #{e.record.errors.full_messages.to_sentence}"
    render :show, status: :unprocessable_entity
  end

  private

  def ensure_cart_not_empty
    return if current_cart.values.sum(&:to_i) > 0

    redirect_to cart_path, alert: "Your cart is empty. Add products before checking out."
  end

  def load_cart_items
    @cart_items = []
    @subtotal = BigDecimal("0")

    current_cart.each do |product_id_str, raw_qty|
      product = Product.find_by(id: product_id_str.to_i)
      quantity = raw_qty.to_i
      next if product.nil? || quantity <= 0

      line_total = product.price.to_d * quantity
      @subtotal += line_total
      @cart_items << {
        product: product,
        quantity: quantity,
        line_total: line_total
      }
    end
  end

def resolve_selected_province
    province_id = params[:province_id].presence || params.dig(:checkout, :province_id).presence
    if province_id
      Province.find_by(id: province_id)
    else
      current_user.province
    end
  end

  def generate_order_number
    "PP-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(3).upcase}"
  end
end