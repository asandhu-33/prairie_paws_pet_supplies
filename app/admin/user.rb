ActiveAdmin.register User do
  menu priority: 4, label: "Customers"

  permit_params :name, :email, :address, :city, :postal_code, :province_id, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :city
    column :province
    column :postal_code
    column "Orders" do |user|
      user.orders.count
    end
    column :created_at
    actions
  end

  filter :name
  filter :email
  filter :city
  filter :province
  filter :created_at

  show do
    attributes_table do
      row :id
      row :name
      row :email
      row :address
      row :city
      row :province
      row :postal_code
      row :created_at
      row :updated_at
    end

    panel "Orders Placed (#{user.orders.count})" do
      if user.orders.any?
        table_for user.orders.order(created_at: :desc) do
          column "Order #" do |order|
            link_to(order.order_number.presence || "Order ##{order.id}", admin_order_path(order))
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
        end
      else
        para "This customer has not placed any orders yet."
      end
    end
  end

  form do |f|
    f.inputs "Customer Account Details" do
      f.input :name
      f.input :email
      f.input :address
      f.input :city
      f.input :province
      f.input :postal_code
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end