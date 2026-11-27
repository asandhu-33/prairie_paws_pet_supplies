ActiveAdmin.register Order do
  actions :index, :show, :edit, :update

  permit_params :status

  controller do
    def scoped_collection
      super.includes(:user, :province, order_items: :product)
    end
  end

  filter :order_number
  filter :status
  filter :user
  filter :province
  filter :shipping_province
  filter :created_at

  index do
    selectable_column
    id_column
    column "Order #" do |order|
      link_to(order.order_number.presence || "Order ##{order.id}", admin_order_path(order))
    end
    column "Customer" do |order|
      if order.user
        link_to(order.user.name.presence || order.user.email, admin_user_path(order.user))
      end
    end
    column "Products Ordered" do |order|
      if order.order_items.any?
        ul style: "margin: 0; padding-left: 16px;" do
          order.order_items.each do |item|
            product_name = item.product&.name || "Product ##{item.product_id}"
            li "#{product_name} × #{item.quantity}"
          end
        end
      else
        span "None", style: "color: #888;"
      end
    end
    column :status
    column :shipping_province
    column :subtotal do |order|
      number_to_currency(order.subtotal || 0)
    end
    column :tax_total do |order|
      number_to_currency(order.tax_total || 0)
    end
    column :total do |order|
      number_to_currency(order.total || 0)
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :order_number
      row "Customer" do |order|
        if order.user
          link_to("#{order.user.name.presence || order.user.email} (#{order.user.email})", admin_user_path(order.user))
        end
      end
      row :status
      row :shipping_address
      row :shipping_city
      row :shipping_postal_code
      row :shipping_province
      row :subtotal do |order|
        number_to_currency(order.subtotal || 0)
      end
      row :gst_amount do |order|
        number_to_currency(order.gst_amount || 0)
      end
      row :pst_amount do |order|
        number_to_currency(order.pst_amount || 0)
      end
      row :hst_amount do |order|
        number_to_currency(order.hst_amount || 0)
      end
      row :tax_total do |order|
        number_to_currency(order.tax_total || 0)
      end
      row :total do |order|
        number_to_currency(order.total || 0)
      end
      row :created_at
    end

    panel "Order Items" do
      table_for order.order_items.includes(:product) do
        column :product do |item|
          item.product&.name || "Product ##{item.product_id}"
        end
        column :quantity
        column :unit_price do |item|
          number_to_currency(item.unit_price || 0)
        end
        column "Line Total" do |item|
          number_to_currency((item.unit_price || 0).to_d * item.quantity.to_i)
        end
      end
    end
  end

  form do |f|
    f.inputs "Order Status" do
      f.input :status
    end
    f.actions
  end
end