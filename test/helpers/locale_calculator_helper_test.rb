require "test_helper"

class LocaleCalculatorHelperTest < ActionView::TestCase
  include LocaleCalculatorHelper

  # --- locale_home_name ---

  test "returns English 'Home' for English locale" do
    I18n.locale = :en
    assert_equal "Home", locale_home_name
  end

  test "returns German 'Startseite' for German locale" do
    I18n.locale = :de
    assert_equal "Startseite", locale_home_name
  ensure
    I18n.locale = :en
  end

  test "returns French 'Accueil' for French locale" do
    I18n.locale = :fr
    assert_equal "Accueil", locale_home_name
  ensure
    I18n.locale = :en
  end

  test "returns Spanish 'Inicio' for Spanish locale" do
    I18n.locale = :es
    assert_equal "Inicio", locale_home_name
  ensure
    I18n.locale = :en
  end

  test "returns Portuguese 'Inicio' for Portuguese locale" do
    I18n.locale = :pt
    assert_equal "Inicio", locale_home_name
  ensure
    I18n.locale = :en
  end

  test "falls back to English 'Home' for unmapped locale" do
    # mk (Macedonian) is a real locale used in the project but isn't in LOCALE_HOME_NAMES —
    # it should fall through to the "Home" default.
    original = I18n.locale
    I18n.available_locales = (I18n.available_locales | [ :mk ]).uniq
    I18n.locale = :mk
    assert_equal "Home", locale_home_name
  ensure
    I18n.locale = original
  end

  # --- locale_faq_data ---

  test "faq_data returns the requested number of question/answer pairs" do
    data = locale_faq_data("finance", "mortgage", count: 3)

    assert_equal 3, data.length
    data.each do |entry|
      assert_equal %i[answer question], entry.keys.sort
    end
  end

  test "faq_data defaults to 5 entries" do
    data = locale_faq_data("finance", "mortgage")
    assert_equal 5, data.length
  end
end
