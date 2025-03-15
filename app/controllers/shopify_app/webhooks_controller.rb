module ShopifyApp
  class WebhooksController < ActionController::Base
    include ShopifyApp::WebhookVerification

    class ShopifyApp::MissingWebhookJobError < StandardError; end

    def receive
      if gdpr_webhook?
        AdminLog.create(name: 'gdpr_webhook', data: job_args)
      else
        webhook_job_klass.perform_later(job_args)
      end
      head :no_content
    end

    private

    def job_args
      @job_args ||= { shop_domain: shop_domain, webhook: webhook_params.to_h }
    end

    def webhook_params
      @webhook_params ||= if %w(products_delete products_update products_create).include?(webhook_type)
        params.permit(:id, :status)
      else
        params.permit!
        params.except(:controller, :action, :type)
      end
    end

    def webhook_job_klass
      webhook_job_klass_name.safe_constantize or raise ShopifyApp::MissingWebhookJobError
    end

    def webhook_job_klass_name(type = webhook_type)
      [webhook_namespace, "#{type}_job"].compact.join('/').classify
    end

    def webhook_type
      params[:type]
    end

    def webhook_namespace
      ShopifyApp.configuration.webhook_jobs_namespace
    end

    def gdpr_webhook?
      %w(customers_redact shop_redact customers_data_request).include?(webhook_type)
    end
  end
end