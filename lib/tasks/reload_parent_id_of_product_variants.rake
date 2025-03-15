namespace :product do
  desc 'Reload parent_id of PictureItProductsVariants'
  task reload_parent_id_of_product_variants: :environment do
    Product.only_parents.find_each do |product|
      Product.by_external_id(product.variants_ids).update_all(parent_id: product.id)
      puts "Updated variants for product #{product.id}, variants: #{product.variants_ids}"
    end

    puts "All variants updated"
  end
end
