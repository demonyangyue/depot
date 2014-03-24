class CombineItemsInCart < ActiveRecord::Migration
  def up
      Cart.all.each do |cart|
          sums = cart.line_items.group(:product_id).sum(:quantity)
          sums.each do |product_id, sum_quantity|
              if sum_quantity > 1
                  cart.line_items.where(product_id: product_id).delete_all

                  line_item = cart.line_items.build(product_id: product_id)
                  line_item.quantity = sum_quantity

                  line_item.save!
              end
          end
      end
  end

  def down
      LineItem.all.each do |item|
          if item.quantity > 1
              item.quantity.times do 
                  LineItem.create(cart_id: item.cart_id, product_id: item.product_id, quantity: 1) 
              end

              item.destroy
          end
      end
  end
end
