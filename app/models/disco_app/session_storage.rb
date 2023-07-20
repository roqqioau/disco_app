module DiscoApp
  class SessionStorage

    class << self
      def store(session, *args)
        shop = DiscoApp::Shop.find_or_initialize_by(shopify_domain: session.shop)
        shop.shopify_token = session.access_token
        shop.access_scopes = session.scope.to_s
        shop.status = DiscoApp::Shop::statuses[:never_installed]
        shop.save!
        shop.id
      end

      def retrieve(id)
        return unless id

        shop = DiscoApp::Shop.valid_status.find_by(id: id)
        construct_session(shop)
      end

      def retrieve_by_shopify_domain(domain)
        shop = DiscoApp::Shop.valid_status.find_by(shopify_domain: domain)
        construct_session(shop)
      end

      private

      def construct_session(shop)
        return unless shop
        # ShopifyAPI::Session.new(domain: shop.shopify_domain, token: shop.shopify_token, api_version: shop.api_version)
        ShopifyAPI::Auth::Session.new(
            shop: shop.shopify_domain,
            access_token: shop.shopify_token,
            scope: shop.access_scopes,
          )
      end
    end
  end
end
