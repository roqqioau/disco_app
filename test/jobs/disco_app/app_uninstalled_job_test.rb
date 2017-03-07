require 'test_helper'

class DiscoApp::AppUninstalledJobTest < ActionController::TestCase
  include ActiveJob::TestHelper

  def setup
    @shop = disco_app_shops(:widget_store)
    stub_request(:post, "https://api.discolabs.com/v1/app_subscriptions.json").
        to_return(status: 200, body: api_fixture('widget_store/carrier_services').to_json)
    perform_enqueued_jobs do
      DiscoApp::AppUninstalledJob.perform_later(@shop, {})
    end
  end

  def teardown
    @shop = nil
    WebMock.reset!
  end

  test 'app uninstalled job changes shop status' do
    assert_performed_jobs 2
    @shop.reload
    assert @shop.uninstalled?
  end

  test 'app uninstalled job can be extended using concerns' do
    assert_performed_jobs 2
    @shop.reload
    assert_equal 'Nowhere', @shop.data['country_name'] # Assert extended method called.
  end

  # test 'app uninstalled job enqueue subscriptionjob to send data to disco API' do
  #   assert_performed_jobs 1 do
  #     DiscoApp::SendSubscriptionJob.perform_later(@shop)
  #   end
  #   @shop.reload
  # end

end
