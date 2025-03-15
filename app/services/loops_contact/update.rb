class LoopsContact::Update
  def initialize(contact)
    @contact = contact
  end

  def update_contact
    begin
      LoopsSdk::Contacts.update(
        email: @contact.admin_email,
        properties: contact_properties,
      )
    rescue StandardError => e
      puts "API request failed with error: #{e.message}"
    end
  end

  private

  def contact_properties
    {
      :planName=> @contact.plan_name,
      :chargeName=> @contact.charge_name,
      :installDate=> @contact.created_at
    }
  end
end
