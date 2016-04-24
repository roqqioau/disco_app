module DiscoApp::Concerns::Shop
  extend ActiveSupport::Concern

  included do
    include ShopifyApp::Shop
    include ActionView::Helpers::DateHelper

    # Define relationships to plans and subscriptions.
    has_many :subscriptions
    has_many :plans, through: :subscriptions

    # Define relationship to sessions.
    has_many :sessions, class_name: 'DiscoApp::Session', dependent: :destroy

    # Define possible installation statuses as an enum.
    enum status: [:never_installed, :awaiting_install, :installing, :installed, :awaiting_uninstall, :uninstalling, :uninstalled]

    # Define some useful scopes.
    scope :status, -> (status) { where status: status }
    scope :installed, -> { where status: statuses[:installed] }
    scope :has_active_shopify_plan, -> { where.not(plan_name: [:cancelled, :frozen, :fraudulent]) }

    # Alias 'with_shopify_session' as 'temp', as per our existing conventions.
    alias_method :temp, :with_shopify_session

    # Return a hash of attributes that should be used to create a new charge for this shop.
    # This method can be overridden by the inheriting Shop class in order to provide charges
    # customised to a particular shop. Otherwise, the default settings configured in application.rb
    # will be used.
    def new_charge_attributes
      {
          type: Rails.configuration.x.shopify_charges_default_type,
          name: DiscoApp.configuration.app_name,
          price: Rails.configuration.x.shopify_charges_default_price,
          trial_days: Rails.configuration.x.shopify_charges_default_trial_days,
      }
    end

    # Convenience method to check if this shop has a current subscription.
    def current_subscription?
      current_subscription.present?
    end

    # Convenience method to get the current subscription for this shop, if any.
    def current_subscription
      subscriptions.current.first
    end

    # Convenience method to get the current plan for this shop, if any.
    def current_plan
      current_subscription&.plan
    end

    # Return the absolute URL to the shop's storefront.
    def url
      "#{protocol}://#{domain}"
    end

    # Return the protocol the shop's storefront uses. This should now always be
    # https as all Shopify stores have SSL enabled.
    def protocol
      'https'
    end

    # Return the absolute URL to the shop's admin.
    def admin_url
      "https://#{shopify_domain}/admin"
    end

    def installed_duration
      distance_of_time_in_words_to_now(created_at.time)
    end

    def pretty_created_at
        created_at.strftime("%B %d, %Y")
    end

  end

end
