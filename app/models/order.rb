class Order < ApplicationRecord
  belongs_to :user
  belongs_to :province
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :status, presence: true

  # Computes tax breakdown and totals from a subtotal and Province record.
  # Supports rates stored either as decimals (e.g., 0.05) or percentages (e.g., 5.0).
  def self.calculate_invoice(subtotal, province)
    sub = subtotal.to_d.round(2)

    gst_rate = normalize_rate(province&.gst_rate)
    pst_rate = normalize_rate(province&.pst_rate)
    hst_rate = normalize_rate(province&.hst_rate)

    gst_amount = (sub * gst_rate).round(2)
    pst_amount = (sub * pst_rate).round(2)
    hst_amount = (sub * hst_rate).round(2)
    tax_total = (gst_amount + pst_amount + hst_amount).round(2)
    total = (sub + tax_total).round(2)

    {
      subtotal: sub,
      gst_rate: gst_rate,
      pst_rate: pst_rate,
      hst_rate: hst_rate,
      gst_amount: gst_amount,
      pst_amount: pst_amount,
      hst_amount: hst_amount,
      tax_total: tax_total,
      total: total
    }
  end

  def self.normalize_rate(raw_rate)
    rate = (raw_rate || 0).to_d
    rate > 1 ? (rate / BigDecimal("100")) : rate
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      id user_id province_id order_number status
      shipping_address shipping_city shipping_postal_code shipping_province
      subtotal gst_rate pst_rate hst_rate
      gst_amount pst_amount hst_amount tax_total total
      created_at updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user province order_items products]
  end
end