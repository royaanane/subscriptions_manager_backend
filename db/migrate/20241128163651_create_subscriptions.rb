class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.string :stripe_subscription_id
      t.integer :state, null: false, default: 0

      t.timestamps
    end
    add_index :subscriptions, :stripe_subscription_id, unique: true
  end
end
