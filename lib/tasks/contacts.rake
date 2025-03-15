namespace :contacts do
  desc "Create LoopsContact for all shops"
  task create_for_all_shops: :environment do
    Shop.find_each do |shop|
      if shop.admin_email.present?
        contact_creator = LoopsContact::Create.new(shop)
        contact_creator.create_contact
        puts "Created contact for #{shop.admin_email}"
      else
        puts "Shop #{shop.id} does not have an admin_email, skipping..."
      end
    end
  end

  desc "Update LoopsContact for all shops"
  task update_for_all_shops: :environment do
    Shop.find_each do |shop|
      if shop.admin_email.present?
        contact_updater = LoopsContact::Update.new(shop)
        contact_updater.update_contact
        puts "Updated contact for #{shop.admin_email}"
      else
        puts "Shop #{shop.id} does not have an admin_email, skipping..."
      end
    end
  end
end
