require "test_helper"

class ErrorPagesTest < ActionDispatch::IntegrationTest
  test "404 page has Calc Hammer branding" do
    html = File.read(Rails.root.join("public/404.html"))
    assert_includes html, "Calc Hammer"
    assert_includes html, "Page Not Found"
    assert_includes html, 'href="/"'
  end

  test "500 page has Calc Hammer branding" do
    html = File.read(Rails.root.join("public/500.html"))
    assert_includes html, "Calc Hammer"
    assert_includes html, "Something Went Wrong"
  end

  test "422 page has Calc Hammer branding" do
    html = File.read(Rails.root.join("public/422.html"))
    assert_includes html, "Calc Hammer"
    assert_includes html, "Unprocessable Request"
  end

  test "400 page has Calc Hammer branding" do
    html = File.read(Rails.root.join("public/400.html"))
    assert_includes html, "Calc Hammer"
    assert_includes html, "Bad Request"
  end

  test "404 page includes link to homepage" do
    html = File.read(Rails.root.join("public/404.html"))
    assert_includes html, "Go to Homepage"
  end

  test "500 page includes link to homepage" do
    html = File.read(Rails.root.join("public/500.html"))
    assert_includes html, "Go to Homepage"
  end
end
