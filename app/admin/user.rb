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