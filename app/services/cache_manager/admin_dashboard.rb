class CacheManager::AdminDashboard
  class << self
    def background_removal_credits
      Rails.cache.fetch('background_removal_credits', expires_in: 12.hours) do
        RemoveBg.account_info.credits.total
      end
    end

    def subscriptions_by_count
      Rails.cache.fetch('subscriptions_by_count', expires_in: 24.hours) do
        active_subscriptions = Shop.where(charge_status: 'activated').map(&:plan_name)
        Hash.new(0).tap { |h| active_subscriptions.each { |subscription| h[subscription] += 1 } }
      end
    end
  end
end
