require 'test_helper'

class SynchronisesTest < ActionDispatch::IntegrationTest

  include ActiveJob::TestHelper
  fixtures :all

  def setup
    @shop = disco_app_shops(:widget_store)
    @product = products(:ipod)
    @routes = DiscoApp::Engine.routes
  end

  def teardown
    @shop = nil
  end

  test 'new product is created when product created webhook is received' do
    perform_enqueued_jobs do
      post_webhook('product_created', :'products/create')
    end

    # Assert the product was created locally, with the correct attributes.
    product = Product.find(632910392)
    assert_equal 'IPod Nano - 8GB', product.data[:title]
  end

  test 'existing product is updated when product updated webhook is received' do
    assert_equal({}, @product.data)

    perform_enqueued_jobs do
      post_webhook('product_updated', :'products/update')
    end

    # Assert the product was updated locally, with the correct attributes.
    @product.reload
    assert_equal 632910393, @product.id
    assert_equal 'IPod Nano - 8GB', @product.data[:title]
  end

  test 'existing product is deleted when product deleted webhook is received' do
    perform_enqueued_jobs do
      post_webhook('product_deleted', :'products/delete')
    end

    assert_equal 0, Product.count
  end

  test 'cart with token for id is updated when cart updated webhook is received' do
    perform_enqueued_jobs do
      post_webhook('cart_updated', :'carts/update')
    end

    # Assert the cart data was correctly updated
    assert_equal 3200.0, carts(:cart).total_price
  end

  test 'shopify api model still allows synchronisation' do
    assert_equal({}, @product.data)

    #shopify_product = ShopifyAPI::Product.new(session: ShopifyAPI::Auth::Session.new(id: "id", shop: "test-shop.myshopify.io", access_token: "this_is_a_test_token"))
    #shopify_product.original_state = JSON.parse(webhook_fixture('product_updated'))
    stub_request(:get, "#{@shop.admin_url}/products/632910392.json").to_return(status: 200, body: api_fixture('widget_store/products/product_updated').to_json)
    shopify_product = ShopifyAPI::Product.find(session: ShopifyAPI::Auth::Session.new(id: "id", shop: "widgets.myshopify.com", access_token: "this_is_a_test_token"),
      id: 632910392,
    )
    Product.synchronise(@shop, shopify_product)

    # Assert the product was updated locally, with the correct attributes.
    @product.reload
    assert_equal 632910393, @product.id
    assert_equal 'IPod Nano - 8GB', @product.data[:title]
  end

  private

    def webhooks_url
      DiscoApp::Engine.routes.url_helpers.webhooks_url
    end

    def post_webhook(fixture_name, webhook_topic)
      body = webhook_fixture(fixture_name)
      post webhooks_url, params: body, headers: { HTTP_X_SHOPIFY_TOPIC: webhook_topic, HTTP_X_SHOPIFY_SHOP_DOMAIN: @shop.shopify_domain, HTTP_X_SHOPIFY_HMAC_SHA256: DiscoApp::WebhookService.calculated_hmac(body, ShopifyApp.configuration.secret) }
    end

end
