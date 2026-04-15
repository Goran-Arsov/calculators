# Calc Hammer — Multi-Category Calculator Hub

A Ruby on Rails web app serving free calculators across multiple
categories (finance, math, health, construction, etc.), optimized
for SEO and Google AdSense revenue. No user authentication.

---

## Tech Stack

- **Ruby on Rails 8+** with Hotwire (Turbo + Stimulus)
- **Tailwind CSS** via `tailwindcss-rails` gem
- **PostgreSQL** in all environments
- **Propshaft** asset pipeline
- **Importmap-rails** for JavaScript (no Node.js, no npm)
- No React, Vue, or any JS framework — Stimulus only

---

## Architecture Rules

### Calculator Logic — POROs in `app/calculators/`

All math/calculation logic lives in Plain Old Ruby Objects under
`app/calculators/`, namespaced by category:

```ruby
# app/calculators/finance/mortgage_calculator.rb
module Finance
  class MortgageCalculator
    def initialize(principal:, annual_rate:, years:)
      @principal = principal.to_f
      @annual_rate = annual_rate.to_f / 100.0
      @years = years.to_i
    end

    def call
      # ... returns a result hash
    end
  end
end
```

**Controllers and views must stay dumb — no calculations there.**

### Controllers — Namespaced by Category

Each category has its own controller module. One action per calculator:

```ruby
# app/controllers/finance/calculators_controller.rb
module Finance
  class CalculatorsController < ApplicationController
    def mortgage; end
    def compound_interest; end
    def loan; end
  end
end
```

### Routes — Namespaced to Produce Clean URLs

```ruby
namespace :finance do
  get "mortgage-calculator", to: "calculators#mortgage"
  get "compound-interest-calculator", to: "calculators#compound_interest"
end
```

This produces URLs like `/finance/mortgage-calculator`.

### Category Landing Pages

Each category has a landing page at `/:category` (e.g., `/finance`)
listing all calculators in that category. Use a `CategoriesController#show`
action driven by a route param.

### Stimulus Controllers

One Stimulus controller per calculator. Results update in real-time
on `input` events — **never on form submission, never on page reload**.

### Ad Slots

Ad slots use a shared partial `_ad_slot.html.erb` with a `slot:` argument.
Never hardcode ad markup in individual views. AdSense `<ins>` tags should
be present but commented out by default.

### Never do unnecessary refactoring

Never remove code that is not an obstacle for your current task. If something which does not interfere with the essence of your task, do NOT remove it. For example, if you are tasked to make better metrics, do NOT remove metrics for 14 day, 28 days, which do not interfere with your task! Upgrade, enhance, do not remove. If in doubt, ask for confirmation!


---

## Directory Structure

```
app/
  calculators/              # PORO calculator classes (all math here)
    finance/                #   e.g. finance/mortgage_calculator.rb
    math/                   #   e.g. math/percentage_calculator.rb
    health/                 #   e.g. health/bmi_calculator.rb
  controllers/
    finance/
      calculators_controller.rb
    math/
      calculators_controller.rb
    health/
      calculators_controller.rb
    categories_controller.rb
    pages_controller.rb
    home_controller.rb
    sitemap_controller.rb
  helpers/
    seo_helper.rb
    calculator_helper.rb
    ad_helper.rb
  views/
    finance/calculators/    # One view per calculator
    math/calculators/
    health/calculators/
    categories/
      show.html.erb         # Category landing page
    home/
      index.html.erb        # Homepage
    layouts/
      application.html.erb
    shared/
      _ad_slot.html.erb
      _nav.html.erb
      _footer.html.erb
      _calculator_card.html.erb
      _related_calculators.html.erb
  javascript/
    controllers/            # One Stimulus controller per calculator
test/
  calculators/              # Unit tests for every PORO calculator
```

---

## Key Commands

```bash
bin/rails server              # Start dev server
bin/rails test                # Run full test suite
bin/rails test test/calculators/  # Run only PORO calculator unit tests
bin/dev                       # Start with Procfile.dev (Tailwind watcher)
```

---

## Code Conventions

- Ruby: 2-space indentation, snake_case everywhere
- ERB: Keep logic out of templates — use helpers for formatting
- Use `number_to_currency` and `number_to_percentage` for financial output
- Tailwind utility classes only — no custom CSS files unless absolutely necessary
- Test every PORO calculator class. Cover edge cases: zero, negative, very large numbers
- Commit messages: imperative mood ("Add mortgage calculator")

---

## SEO Requirements (Every Calculator Page)

Every calculator view MUST include:
- Unique `<title>` and `<meta name="description">`
- A single `<h1>` with the target keyword
- ~400 words of explanatory content below the calculator UI
  with proper `<h2>`/`<h3>` subheadings
- FAQ schema markup (JSON-LD) with 3-5 Q&As
- Canonical tag with the full URL
- Open Graph tags (`og:title`, `og:description`, `og:url`, `og:type`)
- Breadcrumb schema (JSON-LD): Home > Category > Calculator

Every category landing page MUST include:
- Unique `<title>`, `<meta description>`, `<h1>`
- Intro paragraph describing the category
- Grid of all calculators in that category with descriptions

---

## Ad Slot Placement (Per Calculator Page)

Use `render "shared/ad_slot", slot: "..."` with these positions:
1. `leaderboard` — above the calculator
2. `in_results` — below results, before article content
3. `in_content` — after first section of article text
4. `sidebar` — sticky 300x600 on desktop

Ads are additive — pages must render perfectly without them.

---

## URL Structure

| Page | URL |
|------|-----|
| Homepage | `/` |
| Category landing | `/:category` (e.g., `/finance`) |
| Calculator | `/:category/:slug` (e.g., `/finance/mortgage-calculator`) |
| Blog index | `/blog` |
| Blog post | `/blog/:slug` |
| Privacy Policy | `/privacy-policy` |
| Terms of Service | `/terms-of-service` |
| Sitemap | `/sitemap.xml` |

---

## What NOT to Do

- Do not add user authentication
- Do not use React, Vue, or any npm-based JS framework
- Do not put calculation logic in controllers or views
- Do not use inline styles — Tailwind classes only
- Do not make ad slots required for page render
- Do not stuff ads above the fold aggressively
- Do not split categories into separate sites/domains
- Do not add a database-backed calculator registry (keep it simple — routes + POROs)

## After you've finished a task, do this:

1) Analyze the changes you've done if they need variable extraction; if it's good practice, extract variables!
2) Analyze the changes you've done if they need scope extraction; if it's good practice, extract scopes!
3) Analyze the changes you've done if they need partial extraction; if it's good practice, extract partial!
4) Analyze the changes you've done if they need code refactoring; if it's good practice, code refactor!
5) Check if the changes you've done need tests written; if tests could be written, write them!
6) Test!
7) Use agent-browser to test the latest work (work done on this issue).



