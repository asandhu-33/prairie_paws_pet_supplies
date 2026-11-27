class ProductsController < ApplicationController
  PER_PAGE = 12

  def index
    @categories = Category.where(name: %w[Dogs Cats]).order(:name)
    @products = Product.includes(:category, :image_attachment).order(created_at: :desc)

    case params[:pet]
    when "dogs"
      dog_cat_id = Category.find_by(name: "Dogs")&.id
      dog_pattern = "%dog%"
      puppy_pattern = "%puppy%"
      @products = @products.where(
        "(category_id = ? OR LOWER(name) LIKE ? OR LOWER(description) LIKE ? OR LOWER(name) LIKE ? OR LOWER(description) LIKE ?) " \
        "AND LOWER(name) NOT LIKE ?",
        dog_cat_id, dog_pattern, dog_pattern, puppy_pattern, puppy_pattern, "%cat%"
      )
    when "cats"
      cat_cat_id = Category.find_by(name: "Cats")&.id
      cat_pattern = "%cat%"
      kitten_pattern = "%kitten%"
      @products = @products.where(
        "(category_id = ? OR LOWER(name) LIKE ? OR LOWER(description) LIKE ? OR LOWER(name) LIKE ? OR LOWER(description) LIKE ?) " \
        "AND LOWER(name) NOT LIKE ?",
        cat_cat_id, cat_pattern, cat_pattern, kitten_pattern, kitten_pattern, "%dog%"
      )
    end

    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end

    if params[:q].present?
      query = "%#{params[:q].strip.downcase}%"
      @products = @products.where("LOWER(name) LIKE ? OR LOWER(description) LIKE ?", query, query)
    end

    case params[:filter]
    when "sale", "on_sale"
      @products = @products.on_sale
    when "new"
      @products = @products.new_products.order(created_at: :desc)
    end

    if @products.respond_to?(:page)
      @products = @products.page(params[:page]).per(PER_PAGE)
    else
      @page = [params[:page].to_i, 1].max
      @total_pages = (@products.count.to_f / PER_PAGE).ceil
      @products = @products.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
    end
  end

  def show
    @product = Product.includes(:category, :image_attachment).find(params[:id])
  end
end