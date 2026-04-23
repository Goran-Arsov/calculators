require "test_helper"

class Everyday::TailwindToCssCalculator::ClassConverterTest < ActiveSupport::TestCase
  CC = Everyday::TailwindToCssCalculator::ClassConverter

  test "returns exact CSS for static mappings" do
    assert_equal "display: flex;", CC.call("flex")
    assert_equal "position: absolute;", CC.call("absolute")
    assert_equal "display: none;", CC.call("hidden")
  end

  test "padding dynamic classes" do
    assert_equal "padding: 1rem;", CC.call("p-4")
    assert_equal "padding-top: 0.5rem;", CC.call("pt-2")
  end

  test "padding axis classes emit both sides" do
    assert_equal "padding-left: 1rem;\npadding-right: 1rem;", CC.call("px-4")
  end

  test "margin dynamic classes" do
    assert_equal "margin: 2rem;", CC.call("m-8")
  end

  test "width and height" do
    assert_equal "width: 100%;", CC.call("w-full")
    assert_equal "height: 1rem;", CC.call("h-4")
  end

  test "fractional width produces percentage" do
    assert_equal "width: 1/2%;", CC.call("w-1/2")
  end

  test "max width uses its own scale" do
    assert_equal "max-width: 42rem;", CC.call("max-w-2xl")
  end

  test "text size emits font-size and line-height" do
    assert_equal "font-size: 1rem;\nline-height: 1.5rem;", CC.call("text-base")
  end

  test "font weight" do
    assert_equal "font-weight: 700;", CC.call("font-bold")
  end

  test "border radius" do
    assert_equal "border-radius: 0.5rem;", CC.call("rounded-lg")
    assert_equal "border-radius: 0.25rem;", CC.call("rounded")
  end

  test "numeric border width" do
    assert_equal "border-width: 4px;", CC.call("border-4")
  end

  test "opacity scales to 0..1" do
    assert_equal "opacity: 0.5;", CC.call("opacity-50")
  end

  test "z-index accepts numeric or auto" do
    assert_equal "z-index: 10;", CC.call("z-10")
    assert_equal "z-index: auto;", CC.call("z-auto")
  end

  test "grid columns" do
    assert_equal "grid-template-columns: repeat(3, minmax(0, 1fr));", CC.call("grid-cols-3")
  end

  test "returns nil for unmapped classes" do
    assert_nil CC.call("absolutely-not-a-tailwind-class")
  end

  test "leading keyword variants" do
    assert_equal "line-height: 1;", CC.call("leading-none")
    assert_equal "line-height: 1.5;", CC.call("leading-normal")
  end

  test "inset applies to all four sides" do
    result = CC.call("inset-4")
    assert_includes result, "top: 1rem;"
    assert_includes result, "right: 1rem;"
    assert_includes result, "bottom: 1rem;"
    assert_includes result, "left: 1rem;"
  end
end
