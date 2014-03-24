require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  #

  test "order attributes must not be empty" do 
    order = Order.new
    assert order.invalid?
    assert order.errors[:name].any?
    assert order.errors[:address].any?
    assert order.errors[:email].any?
    assert order.errors[:pay_type].any?
  end

  test "pay type should be one of payment_types" do
    order = orders(:one)
    assert order.valid?
    order.pay_type = "Undefined"
    assert order.invalid?
    assert order.errors[:pay_type].any?
    
  end
end
