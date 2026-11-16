class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.references :province, null: false, foreign_key: true
      t.string :order_number
      t.string :status
      t.string :shipping_address
      t.string :shipping_city
      t.string :shipping_postal_code
      t.string :shipping_province
      t.decimal :subtotal
      t.decimal :gst_rate
      t.decimal :pst_rate
      t.decimal :hst_rate
      t.decimal :gst_amount
      t.decimal :pst_amount
      t.decimal :hst_amount
      t.decimal :tax_total
      t.decimal :total

      t.timestamps
    end
  end
end
