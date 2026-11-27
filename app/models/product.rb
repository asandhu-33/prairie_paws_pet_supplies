class Product < ApplicationRecord
  belongs_to :category
  has_one_attached :image

  validates :name, :description, :price, :stock, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :on_sale, -> { where(on_sale: true) }
  scope :new_products, -> { where("created_at >= ?", 3.days.ago) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name description price stock on_sale category_id created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[category image_attachment image_blob]
  end
end