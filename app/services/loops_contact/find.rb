class LoopsContact::Find
  def initialize(contact)
    @contact = contact
  end

  def contact_exists?
    begin
      LoopsSdk::Contacts.find(email: @contact.admin_email)&.any?   
    rescue StandardError => e
      puts "API request failed with error: #{e.message}"
      false
    end
  end
end
