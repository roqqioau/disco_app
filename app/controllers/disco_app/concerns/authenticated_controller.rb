module DiscoApp::Concerns::AuthenticatedController

  extend ActiveSupport::Concern
  include ShopifyApp::LoginProtection
  include ShopifyApp::Localization
  include ShopifyApp::EmbeddedApp
  included do
    before_action :auto_login
    before_action :check_shop_whitelist
    before_action :login_again_if_different_user_or_shop
    before_action :shopify_shop
    before_action :check_installed
    before_action :check_current_subscription
    before_action :check_active_charge
    around_action :activate_shopify_session
    layout 'embedded_app'
  end


  def check_request_hmac_valid
    head :unauthorized unless request_hmac_valid?
  end

  private

    def auto_login
      return unless current_shopify_session.blank? && request_hmac_valid? && !DiscoApp.configuration.disable_auto_login?

      shop = DiscoApp::Shop.find_by(shopify_domain: sanitized_shop_name)
      return if shop.blank?

      #session[:shopify] = shop.id
      #session[:shopify_domain] = sanitized_shop_name
      cookie = ShopifyAPI::Auth::Oauth::SessionCookie.new(value: "offline_#{sanitized_shop_name}", expires: nil)
      cookies.encrypted[cookie.name] = {
        expires: cookie.expires,
        secure: true,
        http_only: true,
        value: cookie.value,
      }
    end

    def shopify_shop
      if current_shopify_session
        @shop = DiscoApp::Shop.find_by!(shopify_domain: @current_shopify_session.shop)
      else
        redirect_to_login
      end
    end

    def check_installed
      if @shop.awaiting_install? || @shop.installing?
        redirect_if_not_current_path disco_app.installing_path
        return
      end
      if @shop.awaiting_uninstall? || @shop.uninstalling?
        redirect_if_not_current_path disco_app.uninstalling_path
        return
      end
      redirect_if_not_current_path disco_app.install_path unless @shop.installed?
    end

    def check_current_subscription
      redirect_if_not_current_path disco_app.new_subscription_path unless @shop.current_subscription?
    end

    def check_active_charge
      return unless @shop.current_subscription?
      return unless @shop.current_subscription.requires_active_charge?
      return if @shop.development?
      return if @shop.current_subscription.active_charge?

      redirect_if_not_current_path disco_app.new_subscription_charge_path(@shop.current_subscription)
    end

    def redirect_if_not_current_path(target)
      redirect_to target if request.path != target
    end

    def request_hmac_valid?
      DiscoApp::RequestValidationService.hmac_valid?(request.query_string, ShopifyApp.configuration.secret)
    end

    def check_shop_whitelist
      return if current_shopify_session.blank?
      return if ENV['WHITELISTED_DOMAINS'].blank?
      return if ENV['WHITELISTED_DOMAINS'].include?(current_shopify_session.shop)

      redirect_to_login
    end

end
