namespace :reload_products_counter_cache do
  desc 'Recalculate enabled_product_variants_count for all products'
  task enabled_product_variants_count: :environment do
    Product.only_parents.find_each do |product|
      product.recalculate_enabled_product_variants_count

      puts "Recalculated enabled_product_variants_count for product #{product.id}"
    end
  end

  desc 'Recalculate product_variants_count for all products'
  task product_variants_count: :environment do
    Product.only_parents.find_each do |product|
      product.recalculate_product_variants_count

      puts "Recalculated product_variants_count for product #{product.id}"
    end
  end
end
