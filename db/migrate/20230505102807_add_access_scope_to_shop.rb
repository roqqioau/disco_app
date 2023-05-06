class AddAccessScopeToShop < ActiveRecord::Migration[6.1]
  def change
    add_column :disco_app_shops, :access_scopes, :string
  end
end
