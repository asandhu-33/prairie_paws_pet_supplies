class Page < ApplicationRecord
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_-]+\z/ }
  validates :title, presence: true, length: { maximum: 150 }
  validates :body, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[body created_at id slug title updated_at]
  end
end