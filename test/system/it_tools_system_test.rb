require "application_system_test_case"

class ItToolsSystemTest < ApplicationSystemTestCase
  # 1. HTTP Status Code Reference
  test "http status code reference loads and displays codes" do
    visit everyday_http_status_reference_path
    assert_selector "h1", text: /HTTP Status/i
    assert_text "200"
    assert_text "404"
    assert_text "500"
  end

  # 2. Open Graph Preview
  test "open graph preview page loads with inputs" do
    visit everyday_og_preview_path
    assert_selector "h1", text: /Open Graph/i
    assert_selector "input", minimum: 2
  end

  # 3. curl to Code Converter
  test "curl to code converter page loads" do
    visit everyday_curl_to_code_path
    assert_selector "h1", text: /curl/i
    assert_selector "textarea", minimum: 1
    assert_selector "button", minimum: 1
  end

  # 4. JSON to YAML Converter
  test "json to yaml converter page loads with textareas" do
    visit everyday_json_to_yaml_path
    assert_selector "h1", text: /JSON.*YAML|YAML.*JSON/i
    assert_selector "textarea", minimum: 1
  end

  # 5. JSON to TypeScript Generator
  test "json to typescript generator page loads" do
    visit everyday_json_to_typescript_path
    assert_selector "h1", text: /TypeScript/i
    assert_selector "textarea", minimum: 1
  end

  # 6. HTML Formatter/Beautifier
  test "html formatter page loads with format button" do
    visit everyday_html_formatter_path
    assert_selector "h1", text: /HTML.*Format/i
    assert_selector "textarea", minimum: 1
    assert_selector "button", text: /Beautify|Format/i
  end

  # 7. CSS Formatter/Beautifier
  test "css formatter page loads with format button" do
    visit everyday_css_formatter_path
    assert_selector "h1", text: /CSS.*Format/i
    assert_selector "textarea", minimum: 1
    assert_selector "button", text: /Beautify|Format/i
  end

  # 8. JavaScript Formatter/Beautifier
  test "js formatter page loads with format button" do
    visit everyday_js_formatter_path
    assert_selector "h1", text: /JavaScript.*Format/i
    assert_selector "textarea", minimum: 1
    assert_selector "button", text: /Beautify|Format/i
  end

  # 9. HTML to JSX Converter
  test "html to jsx converter page loads" do
    visit everyday_html_to_jsx_path
    assert_selector "h1", text: /JSX/i
    assert_selector "textarea", minimum: 1
    assert_selector "button", text: /Convert/i
  end

  # 10. Robots.txt Generator
  test "robots txt generator page loads" do
    visit everyday_robots_txt_path
    assert_selector "h1", text: /robots/i
    assert_selector "button", minimum: 1
  end

  # 11. SVG to PNG Converter
  test "svg to png converter page loads with textarea" do
    visit everyday_svg_to_png_path
    assert_selector "h1", text: /SVG.*PNG/i
    assert_selector "textarea", minimum: 1
  end

  # 12. Base64 Encoder/Decoder
  test "base64 encoder encodes text correctly" do
    visit everyday_base64_encoder_path
    assert_selector "h1", text: /Base64/i

    # Find input textarea and type text
    textareas = all("textarea")
    textareas.first.set("Hello World")

    # Click encode button
    click_on_button_with_text("Encode")
    sleep 0.5

    # Check output textarea contains the base64
    output = textareas.last.value rescue all("textarea").last.value
    assert_match(/SGVsbG8gV29ybGQ/, output, "Expected Base64 encoding of 'Hello World'")
  end

  # 13. URL Encoder/Decoder
  test "url encoder encodes text correctly" do
    visit everyday_url_encoder_path
    assert_selector "h1", text: /URL/i

    textareas = all("textarea")
    textareas.first.set("hello world")

    click_on_button_with_text("Encode")
    sleep 0.5

    output = all("textarea").last.value
    assert_match(/hello(%20|\+)world/, output, "Expected URL encoding of 'hello world'")
  end

  # 14. Hex/ASCII Converter
  test "hex ascii converter converts text to hex" do
    visit everyday_hex_ascii_path
    assert_selector "h1", text: /Hex/i

    textareas = all("textarea")
    textareas.first.set("Hi")

    click_on_button_with_text("Hex")
    sleep 0.5

    output = all("textarea").last.value
    # "H"=72=0x48, "i"=105=0x69 -- tool may output hex or decimal
    assert_match(/48.*69|72.*105/i, output, "Expected hex or decimal values for 'Hi'")
  end

  # --- IT Tools landing page ---
  test "information technology page loads with categories" do
    visit it_tools_path
    assert_selector "h1", text: /IT Tools/i
    assert_text "Security"
    assert_text "Encoding"
    assert_text "Networking"
  end

  private

  def click_on_button_with_text(text)
    btn = all("button").find { |b| b.text.strip.match?(/#{text}/i) }
    btn&.click
  end
end
