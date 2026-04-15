# Calc Hammer — Multi-Category Calculator Hub

A Ruby on Rails web app serving free calculators across multiple
categories (economy, math, health, etc.), optimized for SEO and
Google AdSense revenue. No user authentication.

---

## Tech Stack

- **Ruby on Rails 8+** with Hotwire (Turbo + Stimulus)
- **Tailwind CSS** via the `tailwindcss-rails` gem
- **SQLite** in development, **PostgreSQL** in production
- **No React, no Vue, no heavy JS frameworks** — keep it lean
- **Stimulus.js** handles all real-time calculator interactivity
- Deploy target: Render or Fly.io

---

## Project Structure

```
app/
  calculators/              # PORO calculator classes (all math logic lives here)
    economy/                #   e.g. economy/mortgage_calculator.rb
    math/                   #   e.g. math/circumference_calculator.rb
    health/                 #   e.g. health/bmi_calculator.rb
  controllers/
    economy/
      calculators_controller.rb
    math/
      calculators_controller.rb
    health/
      calculators_controller.rb
  views/
    economy/calculators/    # One view per calculator, namespaced by category
    math/calculators/
    health/calculators/
    categories/
      show.html.erb         # Category landing page (e.g. /economy)
    layouts/
      application.html.erb
    shared/
      _ad_slot.html.erb
      _nav.html.erb
      _footer.html.erb
  javascript/
    controllers/            # One Stimulus controller per calculator
```

---

## Architecture Rules

- **All math logic goes in `app/calculators/`** as Plain Old Ruby Objects
  (POROs), namespaced by category (e.g. `Economy::MortgageCalculator`).
  Views and controllers must stay dumb — no calculations there.
- **Controllers are namespaced by category.** Each category has its own
  module: `Economy::CalculatorsController`, `Math::CalculatorsController`,
  etc. One action per calculator within that controller.
- **Routes use nested namespaces** to produce URLs like
  `/economy/mortgage-calculator` and `/math/circumference-calculator`.
  Use Rails `namespace` blocks in `routes.rb`:
  ```ruby
  namespace :economy do
    get "mortgage-calculator", to: "calculators#mortgage"
    get "compound-interest-calculator", to: "calculators#compound_interest"
  end
  namespace :math do
    get "circumference-calculator", to: "calculators#circumference"
    get "percentage-calculator", to: "calculators#percentage"
  end
  ```
- **Each category also has a landing page** at `/:category` (e.g. `/economy`,
  `/math`) listing all calculators in that category. Use a
  `CategoriesController#show` action driven by a route param.
- One Stimulus controller per calculator. Real-time results update on
  `input` events — never on form submission.
- Ad slots are shared partials (`_ad_slot.html.erb`). Never hardcode ad
  markup in individual views.

---

## Key Commands

```bash
bin/rails server          # Start dev server
bin/rails test            # Run test suite
bin/rails test test/calculators/  # Run only PORO unit tests
bin/rails assets:precompile  # Precompile for production check
```

---

## Code Conventions

- Ruby: 2-space indentation, snake_case everywhere
- ERB: Keep logic out of templates — use helpers for formatting
- Use `number_to_currency` and `number_to_percentage` Rails helpers
  for all financial output formatting
- CSS: Tailwind utility classes only — no custom CSS files unless
  absolutely necessary
- Test every PORO calculator class with unit tests. Aim for full
  coverage of edge cases (zero values, very large numbers, etc.)
- Commit messages: imperative mood ("Add mortgage calculator PORO")

---

## SEO Requirements (apply to every page)

Every calculator view must include:
- Unique `<title>` and `<meta name="description">` via the `meta-tags` gem
- A single `<h1>` with the target keyword
- ~400 words of explanatory article content below the calculator UI
  using proper `<h2>` / `<h3>` subheadings
- FAQ schema markup (JSON-LD) with 3–5 Q&As
- Canonical tag (important: canonical must reflect the full namespaced
  URL, e.g. `https://mycalcs.com/economy/mortgage-calculator`)
- Open Graph tags
- Breadcrumb schema (JSON-LD): Home → Category → Calculator name

Every category landing page (`/economy`, `/math`, etc.) must include:
- Its own unique `<title>`, `<meta description>`, and `<h1>`
- A short intro paragraph describing the category
- A grid/list of all calculators in that category with descriptions

---

## Ad Slot Placement (per calculator page)

Use the `_ad_slot` partial with a `slot:` argument. Slots:
1. `leaderboard` — above the calculator
2. `in_results` — below results, before article content
3. `in_content` — after first section of article text
4. `sidebar` — sticky 300x600 on desktop

AdSense `<ins>` tags should be present but commented out by default,
ready to activate after AdSense approval.

---

## URL Structure & Pages

**Homepage**
- `/` — Lists all categories with featured calculators from each

**Category landing pages**
- `/:category` — e.g. `/economy`, `/math`, `/health`
  Lists all calculators in that category.

**Calculator pages** follow the pattern `/:category/:calculator-name`

Initial categories and calculators to build:

Economy (`/economy/`)
- `mortgage-calculator`
- `compound-interest-calculator`
- `loan-calculator`
- `investment-calculator`
- `retirement-calculator`
- `debt-payoff-calculator`
- `salary-calculator`
- `savings-goal-calculator`

Math (`/math/`)
- `circumference-calculator`
- `percentage-calculator`
- `fraction-calculator`
- `area-calculator`
- `exponent-calculator`

Health (`/health/`)
- `bmi-calculator`
- `calorie-calculator`
- `body-fat-calculator`

**Static pages**
- `/privacy-policy` — required for AdSense
- `/terms-of-service` — required for AdSense
- `/sitemap.xml` — via `sitemap_generator` gem (must include all
  category pages and all calculator pages)

---

## What NOT to Do

- Do not add user authentication
- Do not use React, Vue, or any npm-heavy frontend framework
- Do not put calculation logic in controllers or views
- Do not use inline styles — use Tailwind classes
- Do not make ad slots required for page render (ads are additive)
