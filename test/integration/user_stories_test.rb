#This is the integration test for user stories
#
#A user goes to the sotre index page. 
#They select a product, adding it to their cart
#They then check_out, filling in their details on the checkout form
#When they submit, an order is created in the database containing their infomation.
#Along with a single line_item corresponding to the product they added to their cart.
#Once the order has been received, an email is send comfirming their purchase.
#If the user update the ship_date of the order , an email is send about the update.
require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  fixtures :products

  test "buying a product" do 
    LineItem.delete_all
    Cart.delete_all
    Order.delete_all
    ruby_book = products(:ruby)
    
    get "/"
    assert_response :success
    assert_template "index"

    xhr :post, '/line_items', product_id: ruby_book.id
    assert_response :success
    cart = Cart.find_by(session[:cart_id])
    assert_equal 1, cart.line_items.size
    assert_equal ruby_book, cart.line_items[0].product

    get "/orders/new"
    assert_response :success
    assert_template :new
    
    post_via_redirect "/orders",
                    order: { name: "Dave Thomas",
                             address: "123 The Street",
                             email: "dave@example.com",
                             ship_date: "2104/02/03",
                             pay_type: "Check" }
    assert_response :success
    assert_template "index"
    assert_equal 0, Cart.all.length


    orders = Order.all
    assert_equal 1, orders.length
    order = orders[0]
    assert_equal 1, order.line_items.length
    assert_equal ruby_book, order.line_items[0].product

    mail = ActionMailer::Base.deliveries.last
    assert_equal ["dave@example.com"], mail.to

    put_via_redirect "/orders/#{order.id}",
      order: { name: "Dave Thomas",
               address: "123 The Street",
               email: "dave@example.com",
               ship_date: "2104/02/05",
               pay_type: "Check" }
      assert_response :success
    mail = ActionMailer::Base.deliveries.last
    assert_equal "Progmatic Store Order Shipped", mail.subject
  end
end
