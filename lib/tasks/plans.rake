namespace :plans do
  desc "Create plans with features for each shop"
  task seed_plans_with_features: :environment do
    Shop.find_each do |shop|
      starter_plan = Plan.create!(name: "Starter", price: 1900, shop: shop, price_pioneer: 1500)

      showroom_feature = Feature.create!(
        name: "Showroom",
        price: 400,
        plan: starter_plan
      )

      professional_plan = Plan.create!(name: "Professional", price: 2900, shop: shop, price_pioneer: 2200)

      showroom_feature = Feature.create!(
        name: "Showroom",
        price: 400,
        plan: professional_plan
      )

    end

    puts "All shops now have their plans with features!"
  end

  desc "Add exclusive plan to specific shops"
  task :add_exclusive_plan, [:email] => :environment do |t, args|

    if args.email.blank?
      puts "Please provide an email address."
      next
    end

    shops = Shop.where(admin_email: args.email)
    
    if shops.empty?
      puts "No shops found with the specified email."
    else
      shops.each do |shop|
        Plan.create!(name: "Professional + Showroom (Exclusive)", price: 1000, shop: shop)
        puts "Exclusive plan added for shop with admin_email #{shop.admin_email}."
      end
    end
  end
end
