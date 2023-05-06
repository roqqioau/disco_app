ShopifyApp.configure do |config|
  config.api_key = ENV['SHOPIFY_APP_API_KEY']
  config.secret = ENV['SHOPIFY_APP_SECRET']
  config.scope = ENV['SHOPIFY_APP_SCOPE']
  config.embedded_app = true
  config.api_version = ENV.fetch('SHOPIFY_APP_API_VERSION', '2019-10')
  config.shop_session_repository = 'DiscoApp::SessionStorage'
end

Rails.application.config.after_initialize do
  if ShopifyApp.configuration.api_key.present? && ShopifyApp.configuration.secret.present?
    ShopifyAPI::Context.setup(
      api_key: ShopifyApp.configuration.api_key,
      api_secret_key: ShopifyApp.configuration.secret,
      api_version: ShopifyApp.configuration.api_version,
      host: ENV['HOST'],
      scope: ShopifyApp.configuration.scope,
      is_private: !ENV.fetch('SHOPIFY_APP_PRIVATE_SHOP', '').empty?,
      is_embedded: ShopifyApp.configuration.embedded_app,
      session_storage: ShopifyApp::SessionRepository,
      logger: Rails.logger,
      private_shop: ENV.fetch('SHOPIFY_APP_PRIVATE_SHOP', nil),
      user_agent_prefix: "ShopifyApp/#{ShopifyApp::VERSION}"
    )

    ShopifyApp::WebhooksManager.add_registrations
  end
end
