# Prairie Paws Pet Supplies
An e-commerce web application built with Ruby on Rails for Prairie Paws Pet Supplies, a locally owned pet supply store in Winnipeg, Manitoba offering everyday essentials for dogs and cats.

## Project Setup 
`rails new prairie_paws_pet_supplies -d postgresql --css=bootstrap` — Generated a Ruby on Rails application configured to use PostgreSQL and Bootstrap CSS.
`cd prairie_paws_pet_supplies` — Navigated into the newly created project directory.
`bundle install` — Installed all required Ruby gem dependencies.
`rails css:install:bootstrap` Installed Bootstrap via Yarn/Node. 

## Database Model and Migration
`rails generate model Province name:string code:string gst_rate:decimal pst_rate:decimal hst_rate:decimal` — Created the `Province` model and migration to store Canadian provinces and their tax rates.
`rails generate model Category name:string description:text` — Created the `Category` model and migration to group products into browsable sections.
`rails generate model Product category:references name:string description:text price:decimal stock:integer on_sale:boolean` — Created the `Product` model and migration linked to categories with pricing, stock, and sale status fields.
`rails generate model Order province:references order_number:string status:string shipping_address:string shipping_city:string shipping_postal_code:string shipping_province:string subtotal:decimal gst_rate:decimal pst_rate:decimal hst_rate:decimal gst_amount:decimal pst_amount:decimal hst_amount:decimal tax_total:decimal total:decimal` — Created the `Order` model and migration to record customer orders, shipping snapshots, tax rates, and totals.
`rails generate model OrderItem order:references product:references quantity:integer unit_price:decimal` — Created the `OrderItem` join model and migration to store ordered quantities and purchase-time prices.
`rails db:create db:migrate` — Created the PostgreSQL databases and ran all migrations to build tables.