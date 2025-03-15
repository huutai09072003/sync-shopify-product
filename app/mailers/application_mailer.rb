class ApplicationMailer < ActionMailer::Base
  layout 'mailer'

  default from: '"Picture It" <help@pictureit.co>'
  default_url_options[:host] = BASE_URL

  # mailer views live in views/mailers
  def self.inherited(subclass)
    subclass.default template_path: "mailers/#{subclass.name.to_s.underscore}"
  end

  after_action :create_mailer_log

  private

  def create_mailer_log
    return unless mail.to
    MailerLog.create(email: mail.to.join(', '), mailer_name: action_name, mailer_subject: mail.subject, mailer_body: mail.body.encoded)
  end
end
