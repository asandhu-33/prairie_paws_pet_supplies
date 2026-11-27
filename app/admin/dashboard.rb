# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Store Overview" do
          ul do
            li "Total Products: #{Product.count}"
            li "Total Categories: #{Category.count}"
            li "Products On Sale: #{Product.where(on_sale: true).count}"
            li "Admin Accounts: #{AdminUser.count}"
          end
        end
      end

      column do
        panel "Recent Products" do
          table_for Product.includes(:category).order(created_at: :desc).limit(5) do
            column("Name") { |product| link_to product.name, admin_product_path(product) }
            column("Category") { |product| product.category&.name }
            column("Price") { |product| number_to_currency(product.price) }
            column("Stock") { |product| product.stock }
          end
        end
      end
    end
  end
end