require "csv"

AdminUser.find_or_create_by!(email: "admin11@gmail.com") do |admin|
  admin.password = "password"
  admin.password_confirmation = "password"
end

csv_path = Rails.root.join("db/data/products.csv")
fallback_categories = [ "Cats", "Birds", "Dogs", "Small Pets" ]
seeded_count = 0

CSV.foreach(csv_path, headers: true) do |row|
  break if seeded_count >= 110

  name = row["title"].to_s.strip.truncate(120)
  next if name.empty?

  parts = row["breadcrumbs"].to_s.split("|").map(&:strip).reject(&:empty?)
  cat_name = parts[1] || parts.first
  cat_name = fallback_categories[seeded_count % 4] if cat_name.blank? || cat_name == "Pet Supplies"

  desc = row["description"].to_s.strip
  desc = row["about_item"].to_s.tr("|", " ").squish if desc.empty?
  desc = "#{name} from Prairie Paws Pet Supplies." if desc.empty?

  price = row["price"].to_s.gsub(/[^0-9.]/, "").to_f
  price = 19.99 unless price.positive?

  category = Category.find_or_create_by!(name: cat_name.truncate(80)) do |c|
    c.description = "Pet supplies for #{cat_name}."
  end

  product = Product.find_or_create_by!(name: name) do |p|
    p.category = category
    p.description = desc.truncate(500)
    p.price = price
    p.stock = 20
    p.on_sale = (seeded_count % 5).zero?
  end

  seeded_count += 1 if product.persisted?
end

puts "Seeded #{Category.count} categories and #{Product.count} products."
