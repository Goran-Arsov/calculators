# Build Prompt: Calc Hammer — Multi-Category Calculator Hub

You are a senior full-stack Ruby on Rails engineer and SEO-focused
product builder. Build a production-ready Rails web application that
serves as a high-performance, multi-category calculator platform
designed for organic search traffic and Google AdSense revenue.

Read `CLAUDE.md` in the project root before doing anything — it
contains the architecture rules, conventions, and constraints for
this project. Follow them exactly.

---

## Step 1: Project Setup

Create a new Rails 8+ application:

```bash
rails new calchammer --database=postgresql --css=tailwind --skip-jbuilder --skip-action-mailbox --skip-action-text --skip-active-storage --skip-action-cable
```

- Use PostgreSQL in all environments
- Use Propshaft (Rails 8 default)
- Use Importmap-rails (no Node.js)
- Use Tailwind CSS via `tailwindcss-rails`
- Skip Action Mailbox, Action Text, Active Storage, Action Cable (not needed)

Add these gems:

```ruby
gem "meta-tags"      # SEO meta tags
gem "sitemap_generator"  # sitemap.xml
gem "rouge"          # Syntax highlighting for blog (optional)
```

Copy `CLAUDE.md` to the project root.

Set up the database and verify the app boots.

---

## Step 2: Core Architecture

### 2a. Create the Calculator PORO Structure

Create `app/calculators/` directory. This is where ALL math logic lives.

Each calculator is a PORO with:
- An `initialize` method accepting named parameters
- A `call` method returning a result hash
- Input validation and edge-case handling

Example:

```ruby
# app/calculators/finance/mortgage_calculator.rb
module Finance
  class MortgageCalculator
    attr_reader :errors

    def initialize(principal:, annual_rate:, years:)
      @principal = principal.to_f
      @annual_rate = annual_rate.to_f / 100.0
      @years = years.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      monthly_rate = @annual_rate / 12.0
      num_payments = @years * 12

      if monthly_rate.zero?
        monthly_payment = @principal / num_payments
      else
        monthly_payment = @principal * (monthly_rate * (1 + monthly_rate)**num_payments) /
                          ((1 + monthly_rate)**num_payments - 1)
      end

      total_paid = monthly_payment * num_payments
      total_interest = total_paid - @principal

      {
        valid: true,
        monthly_payment: monthly_payment.round(2),
        total_paid: total_paid.round(2),
        total_interest: total_interest.round(2),
        num_payments: num_payments
      }
    end

    private

    def validate!
      @errors << "Principal must be positive" unless @principal > 0
      @errors << "Loan term must be positive" unless @years > 0
      @errors << "Interest rate cannot be negative" if @annual_rate < 0
    end
  end
end
```

### 2b. Create Namespaced Controllers

Each category gets its own controller module with one action per calculator:

```ruby
# app/controllers/finance/calculators_controller.rb
module Finance
  class CalculatorsController < ApplicationController
    def mortgage
      # View handles everything via Stimulus
    end

    def compound_interest; end
    def loan; end
    def investment; end
    def retirement; end
    def debt_payoff; end
    def salary; end
    def savings_goal; end
  end
end
```

Repeat for `Math::CalculatorsController`, `Health::CalculatorsController`, etc.

### 2c. Categories Controller

```ruby
# app/controllers/categories_controller.rb
class CategoriesController < ApplicationController
  CATEGORIES = {
    "finance" => {
      title: "Finance Calculators",
      description: "Free financial calculators for mortgage, loans, investments, and more.",
      calculators: [
        { name: "Mortgage Calculator", slug: "mortgage-calculator", description: "Calculate your monthly mortgage payment, total interest, and amortization schedule.", icon: "home" },
        # ... all calculators in this category
      ]
    },
    "math" => { ... },
    "health" => { ... }
  }.freeze

  def show
    @slug = params[:category]
    @category = CATEGORIES[@slug]
    raise ActionController::RoutingError, "Not Found" unless @category
  end
end
```

### 2d. Routes

```ruby
Rails.application.routes.draw do
  # Category landing pages
  get ":category", to: "categories#show", as: :category,
      constraints: { category: /finance|math|health|construction|tax|business/ }

  # Finance calculators
  namespace :finance do
    get "mortgage-calculator", to: "calculators#mortgage", as: :mortgage
    get "compound-interest-calculator", to: "calculators#compound_interest", as: :compound_interest
    get "loan-calculator", to: "calculators#loan", as: :loan
    get "investment-calculator", to: "calculators#investment", as: :investment
    get "retirement-calculator", to: "calculators#retirement", as: :retirement
    get "debt-payoff-calculator", to: "calculators#debt_payoff", as: :debt_payoff
    get "salary-calculator", to: "calculators#salary", as: :salary
    get "savings-goal-calculator", to: "calculators#savings_goal", as: :savings_goal
  end

  # Math calculators
  namespace :math do
    get "percentage-calculator", to: "calculators#percentage", as: :percentage
    get "fraction-calculator", to: "calculators#fraction", as: :fraction
    get "area-calculator", to: "calculators#area", as: :area
    get "circumference-calculator", to: "calculators#circumference", as: :circumference
    get "exponent-calculator", to: "calculators#exponent", as: :exponent
  end

  # Health calculators
  namespace :health do
    get "bmi-calculator", to: "calculators#bmi", as: :bmi
    get "calorie-calculator", to: "calculators#calorie", as: :calorie
    get "body-fat-calculator", to: "calculators#body_fat", as: :body_fat
  end

  # Blog
  get "blog", to: "blog#index", as: :blog
  get "blog/:slug", to: "blog#show", as: :blog_post

  # Static pages
  get "privacy-policy", to: "pages#privacy_policy", as: :privacy_policy
  get "terms-of-service", to: "pages#terms_of_service", as: :terms_of_service
  get "about", to: "pages#about", as: :about

  # SEO
  get "sitemap.xml", to: "sitemap#show", defaults: { format: :xml }
  get "robots.txt", to: "robots#show", defaults: { format: :text }

  root "home#index"
end
```

---

## Step 3: Layout and Shared Components

### 3a. Application Layout

- Mobile-first responsive design
- Sticky navigation with category links
- Footer with internal links (categories, static pages)
- Dark mode support via Tailwind `dark:` variants (toggle with Stimulus)
- `<meta>` tags via the `meta-tags` gem in `<head>`

### 3b. Shared Partials

Create these reusable partials:

**`shared/_nav.html.erb`** — Responsive navbar with category dropdown,
dark mode toggle, and site branding.

**`shared/_footer.html.erb`** — Links to all categories, static pages,
and a brief site description for SEO.

**`shared/_ad_slot.html.erb`** — Accepts a `slot:` local variable
(`leaderboard`, `in_results`, `in_content`, `sidebar`). Renders a
placeholder `<div>` with data attributes. AdSense `<ins>` tags are
present but commented out:

```erb
<%# shared/_ad_slot.html.erb %>
<div class="ad-slot ad-slot--<%= slot %>" data-ad-slot="<%= slot %>">
  <%# Uncomment after AdSense approval:
  <ins class="adsbygoogle"
       style="display:block"
       data-ad-client="ca-pub-XXXXXXXX"
       data-ad-slot="YYYYYYYY"
       data-ad-format="auto"
       data-full-width-responsive="true"></ins>
  <script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
  %>
  <div class="bg-gray-100 dark:bg-gray-800 rounded-lg p-4 text-center text-sm text-gray-400 min-h-[90px] flex items-center justify-center">
    Ad Space
  </div>
</div>
```

**`shared/_calculator_card.html.erb`** — Card component for category
landing pages showing calculator name, description, and link.

**`shared/_related_calculators.html.erb`** — "Related Calculators"
section shown at the bottom of each calculator page. Accepts a list
of related calculator links.

**`shared/_breadcrumbs.html.erb`** — Visual breadcrumb trail that
matches the JSON-LD breadcrumb schema.

---

## Step 4: SEO Infrastructure

### 4a. SEO Helper

Create `app/helpers/seo_helper.rb` with methods for:
- `breadcrumb_schema(items)` — JSON-LD BreadcrumbList
- `faq_schema(questions)` — JSON-LD FAQPage
- `calculator_schema(name:, description:, url:, category:)` — JSON-LD SoftwareApplication
- `set_meta_tags_for_calculator(title:, description:, url:, category:)` — sets title, description, OG tags, canonical

### 4b. Per-Page SEO

Every calculator view must call the SEO helper to set:
- `<title>`: "Mortgage Calculator - Free Online Tool | Calc Hammer"
- `<meta description>`: Unique, keyword-rich, ~155 characters
- Canonical URL
- Open Graph tags
- JSON-LD: BreadcrumbList + FAQPage

### 4c. Sitemap

Use `sitemap_generator` gem. The sitemap must include:
- Homepage
- All category landing pages
- All individual calculator pages
- All blog posts
- Static pages (privacy, terms, about)

### 4d. Robots.txt

Dynamic `robots.txt` via controller:
```
User-agent: *
Allow: /
Sitemap: https://DOMAIN/sitemap.xml
```

---

## Step 5: Calculator Pages

### Page Layout (Every Calculator)

Each calculator page follows this exact structure:

```
[Breadcrumbs: Home > Finance > Mortgage Calculator]
[Ad: leaderboard]
<h1>Mortgage Calculator</h1>
<p class="lead">Brief one-sentence description.</p>

[Calculator UI — inputs + results panel, side by side on desktop]

[Ad: in_results]

<article>
  <h2>How to Calculate Your Mortgage Payment</h2>
  <p>~400 words of helpful, original content...</p>

  [Ad: in_content]

  <h2>Mortgage Payment Formula</h2>
  <p>The formula explanation with rendered formula...</p>

  <h2>Frequently Asked Questions</h2>
  [FAQ items — also rendered as JSON-LD schema]
</article>

[Related Calculators section]
[Ad: sidebar — sticky on desktop]
```

### Stimulus Controller Pattern

Each calculator gets its own Stimulus controller that:
1. Reads input values on every `input` event
2. Validates inputs client-side
3. Calculates results using JavaScript (mirrors the PORO logic)
4. Updates the results panel in real-time (no server round-trip)
5. Supports a "Copy Result" button
6. Supports a "Share" button (copies URL with query params to clipboard)

```javascript
// app/javascript/controllers/mortgage_calculator_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["principal", "rate", "years", "monthlyPayment", "totalPaid", "totalInterest"]

  calculate() {
    const principal = parseFloat(this.principalTarget.value) || 0
    const annualRate = parseFloat(this.rateTarget.value) / 100
    const years = parseInt(this.yearsTarget.value) || 0

    // ... calculation logic mirroring the Ruby PORO
    // ... update targets with formatted results
  }
}
```

---

## Step 6: Initial Calculators to Build

### Priority 1 — Finance (highest CPC: $5-50+)

Build these first with full SEO content:

| Calculator | Key Inputs | Key Outputs |
|-----------|------------|-------------|
| Mortgage Calculator | Principal, rate, years | Monthly payment, total interest, amortization |
| Compound Interest | Principal, rate, years, frequency | Future value, total interest earned |
| Loan Calculator | Amount, rate, term | Monthly payment, total cost, payoff date |
| Investment Calculator | Initial, monthly contribution, rate, years | Future value, total contributions, growth |
| Retirement Calculator | Current age, retire age, savings, monthly contribution, rate | Projected savings, monthly retirement income |
| Debt Payoff Calculator | Balance, rate, monthly payment | Payoff date, total interest, payoff schedule |
| Salary Calculator | Annual/hourly, hours/week | Hourly, daily, weekly, biweekly, monthly, annual equivalents |
| Savings Goal Calculator | Goal amount, timeline, rate | Required monthly savings |

### Priority 2 — Math (low CPC but massive volume for authority)

| Calculator | Key Inputs | Key Outputs |
|-----------|------------|-------------|
| Percentage Calculator | Value, percentage (multiple modes) | Result, step-by-step |
| Fraction Calculator | Two fractions, operation | Result as fraction and decimal |
| Area Calculator | Shape selection, dimensions | Area in multiple units |
| Circumference Calculator | Radius or diameter | Circumference, area |
| Exponent Calculator | Base, exponent | Result |

### Priority 3 — Health

| Calculator | Key Inputs | Key Outputs |
|-----------|------------|-------------|
| BMI Calculator | Height, weight, unit system | BMI value, category, healthy range |
| Calorie Calculator | Age, sex, height, weight, activity | TDEE, deficit/surplus targets |
| Body Fat Calculator | Measurements, sex | Body fat %, category |

---

## Step 7: Homepage

The homepage at `/` should include:
- Hero section with site title, tagline, and search (optional)
- "Popular Calculators" section — grid of 6-8 most useful calculators
- Category sections — each category with 3 featured calculators and
  a "View all" link to the category landing page
- Internal linking to all categories in footer and nav
- Full SEO meta tags, OG tags

---

## Step 8: Blog

Create a simple blog for targeting long-tail SEO keywords.

### Model

```ruby
# BlogPost — title, slug, body (rendered Markdown or HTML), excerpt,
#   meta_title, meta_description, published_at, category (string)
```

### Features
- Admin creates posts by seeding or via rails console (no admin UI needed for v1)
- Index page at `/blog` with pagination
- Show page at `/blog/:slug` with full SEO
- Related calculators linked from blog posts
- Category filter on blog index

### Initial Blog Posts to Seed

Create 3-5 seed posts targeting long-tail keywords:
- "How to Calculate Your Monthly Mortgage Payment (Step by Step)"
- "Compound Interest Explained: The Most Powerful Force in Finance"
- "BMI Chart: What Your BMI Score Really Means"

---

## Step 9: Performance

- **Fragment caching** on calculator cards, category listings, and
  blog post lists using `cache` blocks
- **HTTP caching** — set `Cache-Control` headers on calculator pages
  (they're static content, cache aggressively):
  ```ruby
  expires_in 1.hour, public: true
  ```
- **Eager loading** — ensure no N+1 queries on blog/category pages
- **Minimal JavaScript** — only Stimulus, no heavy libraries
- **Optimized Tailwind** — purge unused styles in production

---

## Step 10: Testing

Write tests for:

### Calculator POROs (most important)

Test every calculator class in `test/calculators/`. Cover:
- Normal inputs (happy path)
- Zero values
- Negative values
- Very large numbers
- Edge cases specific to each calculator (e.g., 0% interest rate for mortgage)
- Validation errors

### Controllers

- Test each calculator action returns 200
- Test category landing pages return 200
- Test unknown categories return 404
- Test homepage renders

### Integration/System

- Test a calculator page has correct meta tags
- Test breadcrumb schema is present
- Test calculator UI updates on input (Capybara system test)

---

## Step 11: Dark Mode

Implement dark mode with a Stimulus controller:
- Toggle button in the navbar
- Persisted to `localStorage`
- Uses Tailwind `dark:` variant classes
- Respects `prefers-color-scheme` on first visit

---

## Step 12: Static Pages

Create these required pages (content can be placeholder for now):

- `/privacy-policy` — Required for AdSense. Include standard privacy
  policy covering cookies, analytics, and ad personalization.
- `/terms-of-service` — Required for AdSense. Standard terms.
- `/about` — Brief description of the site and its purpose.

---

## Step 13: Deployment Prep

- `Dockerfile` for containerized deployment
- `Procfile` for Render/Fly.io
- Environment variable for `DOMAIN` (used in canonical URLs, sitemap)
- Production-ready `database.yml`
- `config/initializers/meta_tags.rb` with site-wide defaults

---

## Build Order

Follow this exact sequence:
1. `rails new` + gems + database setup
2. Layout, nav, footer, ad slot partial
3. SEO helper + meta-tags configuration
4. Category controller + landing pages
5. Homepage
6. **Finance calculators** (all 8) — POROs, Stimulus controllers, views with full SEO content
7. Math calculators (all 5)
8. Health calculators (all 3)
9. Blog model + controller + seed posts
10. Sitemap, robots.txt, static pages
11. Dark mode
12. Fragment caching + HTTP caching
13. Tests for all calculator POROs
14. Controller and integration tests
15. Deployment config

---

## Quality Checklist

Before considering any calculator "done", verify:
- [ ] PORO in `app/calculators/` with `call` method
- [ ] Unit tests covering happy path + edge cases
- [ ] Stimulus controller with real-time updates on `input`
- [ ] Unique `<title>` and `<meta description>`
- [ ] `<h1>` with target keyword
- [ ] ~400 words of explanatory content with `<h2>`/`<h3>` structure
- [ ] FAQ section (3-5 questions) + JSON-LD FAQPage schema
- [ ] Breadcrumb (visual + JSON-LD schema)
- [ ] Canonical tag
- [ ] Open Graph tags
- [ ] 4 ad slot placements
- [ ] Related calculators section
- [ ] Mobile-responsive layout
- [ ] Results formatted with `number_to_currency` / `number_to_percentage` where applicable
- [ ] Copy/share result functionality
