require "test_helper"

class Finance::TipPoolingCalculatorTest < ActiveSupport::TestCase
  test "happy path: distribute by hours" do
    staff = [
      { name: "Alice", hours: 8 },
      { name: "Bob", hours: 6 },
      { name: "Carol", hours: 4 }
    ]
    calc = Finance::TipPoolingCalculator.new(staff: staff, total_tips: 360, method: "hours")
    result = calc.call

    assert result[:valid]
    assert_equal 3, result[:staff_count]
    assert_in_delta 120, result[:average_tip], 0.01

    alice = result[:distribution].find { |d| d[:name] == "Alice" }
    assert_in_delta 160, alice[:tip_amount], 0.01
    assert_in_delta 44.44, alice[:share_percent], 0.01

    bob = result[:distribution].find { |d| d[:name] == "Bob" }
    assert_in_delta 120, bob[:tip_amount], 0.01
  end

  test "distribute by points" do
    staff = [
      { name: "Server", points: 10 },
      { name: "Busser", points: 5 }
    ]
    calc = Finance::TipPoolingCalculator.new(staff: staff, total_tips: 150, method: "points")
    result = calc.call

    assert result[:valid]
    server = result[:distribution].find { |d| d[:name] == "Server" }
    assert_in_delta 100, server[:tip_amount], 0.01
  end

  test "equal hours gives equal tips" do
    staff = [
      { name: "A", hours: 5 },
      { name: "B", hours: 5 }
    ]
    calc = Finance::TipPoolingCalculator.new(staff: staff, total_tips: 200, method: "hours")
    result = calc.call

    assert result[:valid]
    result[:distribution].each do |d|
      assert_in_delta 100, d[:tip_amount], 0.01
      assert_in_delta 50, d[:share_percent], 0.01
    end
  end

  test "fewer than two staff returns error" do
    staff = [ { name: "Alice", hours: 8 } ]
    calc = Finance::TipPoolingCalculator.new(staff: staff, total_tips: 100, method: "hours")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "At least two staff members are required"
  end

  test "zero tips returns error" do
    staff = [
      { name: "A", hours: 5 },
      { name: "B", hours: 5 }
    ]
    calc = Finance::TipPoolingCalculator.new(staff: staff, total_tips: 0, method: "hours")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Total tips must be positive"
  end

  test "staff with zero hours returns error" do
    staff = [
      { name: "A", hours: 5 },
      { name: "B", hours: 0 }
    ]
    calc = Finance::TipPoolingCalculator.new(staff: staff, total_tips: 100, method: "hours")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Staff member 2 hours must be positive"
  end

  test "invalid method returns error" do
    staff = [
      { name: "A", hours: 5 },
      { name: "B", hours: 5 }
    ]
    calc = Finance::TipPoolingCalculator.new(staff: staff, total_tips: 100, method: "random")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Method must be 'hours' or 'points'"
  end

  test "empty name returns error" do
    staff = [
      { name: "", hours: 5 },
      { name: "B", hours: 5 }
    ]
    calc = Finance::TipPoolingCalculator.new(staff: staff, total_tips: 100, method: "hours")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Staff member 1 name is required"
  end
end
