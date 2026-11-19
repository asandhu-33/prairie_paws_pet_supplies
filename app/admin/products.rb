ActiveAdmin.register Product do
  permit_params :name, :description, :price, :stock, :on_sale, :category_id, :image

  filter :name
  filter :category
  filter :price
  filter :on_sale
end
