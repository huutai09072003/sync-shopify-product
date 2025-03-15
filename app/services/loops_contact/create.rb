class LoopsContact::Create
  def initialize(contact)
    @contact = contact
  end

  def create_contact
    begin
      LoopsSdk::Contacts.create(
        email: @contact.admin_email,
        properties: contact_properties,
        mailing_lists: mailing_lists
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

  def mailing_lists
    key = ENV['MAILING_LIST_KEY']&.to_sym
    {
      key => true,
    }
  end
end
