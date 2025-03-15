class LoopsContact::HandleAudience
  def initialize(contact)
    @contact = contact
  end

  def handle_contact
    if LoopsContact::Find.new(@contact).contact_exists?
      LoopsContact::Update.new(@contact).update_contact
    else
      LoopsContact::Create.new(@contact).create_contact
    end
  end
end
