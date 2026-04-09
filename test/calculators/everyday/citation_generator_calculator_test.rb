require "test_helper"

class Everyday::CitationGeneratorCalculatorTest < ActiveSupport::TestCase
  # --- Book citations ---

  test "book citation with single author" do
    result = Everyday::CitationGeneratorCalculator.new(
      source_type: "book", authors: "John Smith", title: "The Art of Research",
      year: "2024", publisher: "Oxford University Press"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:apa_citation], "Smith, J."
    assert_includes result[:apa_citation], "(2024)"
    assert_includes result[:apa_citation], "Oxford University Press"
    assert_includes result[:mla_citation], "Smith, John"
    assert_includes result[:chicago_citation], "Smith, John"
  end

  test "book citation with multiple authors" do
    result = Everyday::CitationGeneratorCalculator.new(
      source_type: "book", authors: "John Smith, Jane Doe", title: "Research Methods",
      year: "2023", publisher: "Cambridge Press"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:apa_citation], "&"
    assert_includes result[:mla_citation], "and Jane Doe"
  end

  test "book citation with three or more authors uses et al in MLA" do
    result = Everyday::CitationGeneratorCalculator.new(
      source_type: "book", authors: "John Smith, Jane Doe, Bob Brown",
      title: "Advanced Methods", year: "2022", publisher: "Academic Press"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:mla_citation], "et al."
  end

  # --- Journal citations ---

  test "journal citation with volume, issue, pages" do
    result = Everyday::CitationGeneratorCalculator.new(
      source_type: "journal", authors: "Alice Johnson", title: "Effects of Study Habits",
      year: "2024", journal_name: "Journal of Education", volume: "12", issue: "3", pages: "45-67"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:apa_citation], "12(3)"
    assert_includes result[:apa_citation], "45-67"
    assert_includes result[:mla_citation], "vol. 12"
    assert_includes result[:mla_citation], "no. 3"
    assert_includes result[:mla_citation], "pp. 45-67"
    assert_includes result[:chicago_citation], "no. 3"
    assert_includes result[:chicago_citation], ": 45-67"
  end

  test "journal citation without optional fields" do
    result = Everyday::CitationGeneratorCalculator.new(
      source_type: "journal", authors: "Alice Johnson", title: "A Brief Study",
      year: "2024", journal_name: "Journal of Science"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:apa_citation], "Journal of Science"
    refute_includes result[:apa_citation], "()"
  end

  # --- Website citations ---

  test "website citation with URL and access date" do
    result = Everyday::CitationGeneratorCalculator.new(
      source_type: "website", authors: "Jane Doe", title: "Understanding Citations",
      year: "2025", url: "https://example.com/article", access_date: "April 9, 2026"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:apa_citation], "https://example.com/article"
    assert_includes result[:apa_citation], "Retrieved April 9, 2026"
    assert_includes result[:mla_citation], "Accessed April 9, 2026"
    assert_includes result[:chicago_citation], "Accessed April 9, 2026"
  end

  test "website citation without access date" do
    result = Everyday::CitationGeneratorCalculator.new(
      source_type: "website", authors: "Jane Doe", title: "Understanding Citations",
      year: "2025", url: "https://example.com/article"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:apa_citation], "https://example.com/article"
    refute_includes result[:apa_citation], "Retrieved"
  end

  # --- Validation errors ---

  test "error with invalid source type" do
    result = Everyday::CitationGeneratorCalculator.new(
      source_type: "podcast", authors: "John Smith", title: "Title", year: "2024"
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Source type") }
  end

  test "error when authors are empty" do
    result = Everyday::CitationGeneratorCalculator.new(
      source_type: "book", authors: "", title: "Title", year: "2024", publisher: "Publisher"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Authors cannot be empty"
  end

  test "error when title is empty" do
    result = Everyday::CitationGeneratorCalculator.new(
      source_type: "book", authors: "John Smith", title: "", year: "2024", publisher: "Publisher"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Title cannot be empty"
  end

  test "error when year is empty" do
    result = Everyday::CitationGeneratorCalculator.new(
      source_type: "book", authors: "John Smith", title: "Title", year: "", publisher: "Publisher"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Year cannot be empty"
  end

  test "error when publisher missing for book" do
    result = Everyday::CitationGeneratorCalculator.new(
      source_type: "book", authors: "John Smith", title: "Title", year: "2024"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Publisher is required for books"
  end

  test "error when journal name missing for journal" do
    result = Everyday::CitationGeneratorCalculator.new(
      source_type: "journal", authors: "John Smith", title: "Title", year: "2024"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Journal name is required for journal articles"
  end

  test "error when URL missing for website" do
    result = Everyday::CitationGeneratorCalculator.new(
      source_type: "website", authors: "John Smith", title: "Title", year: "2024"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "URL is required for websites"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::CitationGeneratorCalculator.new(
      source_type: "book", authors: "John Smith", title: "Title", year: "2024", publisher: "Publisher"
    )
    assert_equal [], calc.errors
  end
end
