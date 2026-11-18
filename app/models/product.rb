ActiveAdmin.register Product do
  permit_params :name, :description, :price, :stock_quantity, :on_sale, :category_id, :image

  index do
    selectable_column
    id_column
    column :name
    column :category
    column :price
    column :stock_quantity
    column :on_sale
    actions
  end

  filter :name
  filter :category
  filter :price
  filter :on_sale

  form do |f|
    f.inputs do
      f.input :category
      f.input :name
      f.input :description
      f.input :price
      f.input :stock_quantity
      f.input :on_sale
      f.input :image, as: :file
    end
    f.actions
  end
end
