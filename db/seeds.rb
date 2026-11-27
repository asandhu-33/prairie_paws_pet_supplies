require "csv"

# 1. Create ActiveAdmin user
AdminUser.find_or_create_by!(email: "anant11@gmail.com") do |admin|
  admin.password = "password"
  admin.password_confirmation = "password"
end

# 2. Seed Canadian provinces and territories with tax rates
provinces = [
  { name: "Alberta", code: "AB", gst: 0.05, pst: 0.0, hst: 0.0 },
  { name: "British Columbia", code: "BC", gst: 0.05, pst: 0.07, hst: 0.0 },
  { name: "Manitoba", code: "MB", gst: 0.05, pst: 0.07, hst: 0.0 },
  { name: "New Brunswick", code: "NB", gst: 0.0, pst: 0.0, hst: 0.15 },
  { name: "Newfoundland and Labrador", code: "NL", gst: 0.0, pst: 0.0, hst: 0.15 },
  { name: "Northwest Territories", code: "NT", gst: 0.05, pst: 0.0, hst: 0.0 },
  { name: "Nova Scotia", code: "NS", gst: 0.0, pst: 0.0, hst: 0.14 },
  { name: "Nunavut", code: "NU", gst: 0.05, pst: 0.0, hst: 0.0 },
  { name: "Ontario", code: "ON", gst: 0.0, pst: 0.0, hst: 0.13 },
  { name: "Prince Edward Island", code: "PE", gst: 0.0, pst: 0.0, hst: 0.15 },
  { name: "Quebec", code: "QC", gst: 0.05, pst: 0.09975, hst: 0.0 },
  { name: "Saskatchewan", code: "SK", gst: 0.05, pst: 0.06, hst: 0.0 },
  { name: "Yukon", code: "YT", gst: 0.05, pst: 0.0, hst: 0.0 }
]

provinces.each do |prov|
  Province.find_or_create_by!(name: prov[:name]) do |p|
    p.code = prov[:code] if p.respond_to?(:code=)
    p.gst = prov[:gst] if p.respond_to?(:gst=)
    p.pst = prov[:pst] if p.respond_to?(:pst=)
    p.hst = prov[:hst] if p.respond_to?(:hst=)
  end
end

# 3. Seed default About and Contact CMS pages
[
  {
    slug: "about",
    title: "About Prairie Paws Pet Supplies",
    body: "Prairie Paws Pet Supplies is a Winnipeg pet supply store dedicated to dogs and cats. We carry trusted food, treats, toys, and everyday essentials for pets of all sizes."
  },
  {
    slug: "contact",
    title: "Contact Us",
    body: "Have a question about dog or cat supplies or an order? Reach out to Prairie Paws Pet Supplies in Winnipeg, Manitoba, or stop by the shop during store hours."
  }
].each do |page_attrs|
  page = Page.find_or_initialize_by(slug: page_attrs[:slug])
  page.update!(title: page_attrs[:title], body: page_attrs[:body]) if page.new_record?
end

# 4. Seed dog and cat products from the CSV dataset
csv_path = Rails.root.join("db/data/products.csv")
fallback_categories = ["Dogs", "Cats"]
seeded_count = 0

dog_keywords = /\b(dog|dogs|puppy|puppies|canine|pooch)\b/i
cat_keywords = /\b(cat|cats|kitten|kittens|feline)\b/i

CSV.foreach(csv_path, headers: true) do |row|
  break if seeded_count >= 110

  name = row["title"].to_s.strip.truncate(120)
  next if name.empty?

  # Use description first, fall back to about_item or a default sentence
  desc = row["description"].to_s.strip
  desc = row["about_item"].to_s.tr("|", " ").squish if desc.empty?
  desc = "#{name} from Prairie Paws Pet Supplies." if desc.empty?

  combined_text = "#{name} #{row['breadcrumbs']} #{desc}"

  # Match product to Dogs or Cats category based on keywords
  cat_name = if combined_text.match?(dog_keywords) && !combined_text.match?(cat_keywords)
               "Dogs"
             elsif combined_text.match?(cat_keywords) && !combined_text.match?(dog_keywords)
               "Cats"
             elsif combined_text.match?(dog_keywords) || combined_text.match?(cat_keywords)
               fallback_categories[seeded_count % 2]
             end

  next if cat_name.nil?

  # Parse numeric price or fall back to $19.99
  price = row["price"].to_s.gsub(/[^0-9.]/, "").to_f
  price = 19.99 unless price.positive?

  category = Category.find_or_create_by!(name: cat_name) do |c|
    c.description = "#{cat_name} supplies at Prairie Paws Pet Supplies."
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

puts "Seeded #{Province.count} provinces, #{Category.count} categories, #{Product.count} products, and #{Page.count} pages."