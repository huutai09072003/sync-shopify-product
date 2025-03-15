class LoopsContact::Delete
  def initialize(contact)
    @contact = contact
  end

  def delete_contact
    begin
      LoopsSdk::Contacts.delete(email: @contact.admin_email)
    rescue StandardError => e
      puts "API request failed with error: #{e.message}"
    end
  end
end
