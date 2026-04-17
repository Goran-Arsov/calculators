require "test_helper"

class Physics::ElementDataTest < ActiveSupport::TestCase
  # --- Dataset invariants ---

  test "ELEMENTS contains all 118 known elements" do
    assert_equal 118, Physics::ElementData::ELEMENTS.length
  end

  test "atomic numbers are contiguous from 1 to 118" do
    zs = Physics::ElementData::ELEMENTS.map { |e| e[:z] }
    assert_equal (1..118).to_a, zs
  end

  test "element symbols are unique" do
    symbols = Physics::ElementData::ELEMENTS.map { |e| e[:symbol] }
    assert_equal symbols.length, symbols.uniq.length
  end

  test "every element has the expected keys" do
    Physics::ElementData::ELEMENTS.each do |e|
      assert_equal %i[z symbol name density state].sort, e.keys.sort,
        "element #{e[:symbol]} has unexpected keys"
    end
  end

  test "states are limited to solid, liquid, and gas" do
    states = Physics::ElementData::ELEMENTS.map { |e| e[:state] }.uniq
    assert_equal %w[gas liquid solid], states.sort
  end

  test "CALCULABLE_ELEMENTS excludes entries with nil density" do
    assert Physics::ElementData::CALCULABLE_ELEMENTS.all? { |e| e[:density] }
    assert_operator Physics::ElementData::CALCULABLE_ELEMENTS.length, :<,
      Physics::ElementData::ELEMENTS.length
  end

  # --- find_by_symbol ---

  test "find_by_symbol returns element hash for a known symbol" do
    iron = Physics::ElementData.find_by_symbol("Fe")

    assert_equal 26, iron[:z]
    assert_equal "Iron", iron[:name]
    assert_in_delta 7.874, iron[:density], 0.0001
  end

  test "find_by_symbol returns nil for unknown symbol" do
    assert_nil Physics::ElementData.find_by_symbol("Zz")
  end

  test "find_by_symbol is case-sensitive" do
    assert_nil Physics::ElementData.find_by_symbol("fe")
    assert_nil Physics::ElementData.find_by_symbol("FE")
  end

  # --- density_for ---

  test "density_for returns density for a known element" do
    assert_in_delta 19.282, Physics::ElementData.density_for("Au"), 0.0001
  end

  test "density_for returns nil for unknown symbol" do
    assert_nil Physics::ElementData.density_for("Zz")
  end

  test "density_for returns nil when the element has no measured density" do
    # Fermium (Fm) and later synthetic elements have nil density.
    assert_nil Physics::ElementData.density_for("Fm")
  end
end
