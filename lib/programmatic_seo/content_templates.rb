require "digest"

module ProgrammaticSeo
  module ContentTemplates
    # Multiple intro templates per category, selected deterministically by
    # base_key+pattern_key. Prevents near-duplicate intros across hundreds of
    # auto-generated pages.
    INTRO_VARIANTS = {
      "finance" => [
        "Understanding your %{noun} %{context} is a critical step in making informed financial decisions. Whether you are planning a major purchase, evaluating an investment, or budgeting for the future, having precise numbers helps you compare options and avoid costly surprises. This calculator provides instant %{noun} estimates %{context}, giving you the clarity you need to move forward with confidence. Simply enter your figures and see results update in real time.",
        "Money decisions get easier when you replace guesswork with concrete numbers. This %{noun} calculator works out the figures %{context} the moment you enter your inputs, so you can compare scenarios side by side without spreadsheet gymnastics. Use it to pressure-test assumptions before you sign anything, share a quote with a partner, or just sanity-check what a lender or seller is telling you.",
        "Behind every smart financial choice is a calculation someone bothered to run. This tool handles the %{noun} math %{context} in seconds, freeing you to focus on the decision itself rather than the arithmetic. Adjust any input and the results update immediately — useful when you want to see how a small change in rate, term, or amount ripples through the final number.",
        "Whether you're stress-testing a budget or comparing offers, getting accurate %{noun} figures %{context} matters. Lenders, advisors, and sellers each have an interest in the numbers; running them yourself with this calculator removes the asymmetry. Inputs are simple and the formulas behind the result are the same ones used in professional financial software."
      ],
      "health" => [
        "Knowing your %{noun} %{context} helps you make better decisions about your health and fitness routine. Everyone's body is different, and generic recommendations often miss important nuances. This calculator tailors the standard %{noun} calculation %{context}, providing personalized results that account for your specific situation. Enter your details below to get science-based estimates that support your wellness goals.",
        "Health metrics are most useful when they reflect your individual situation, not a population average. This %{noun} calculator estimates your number %{context} using established formulas, then frames the result in plain terms you can act on. Track changes over time by recalculating periodically — a single number is a snapshot, but a trend tells the real story.",
        "Self-tracking works best when the numbers you collect are accurate and easy to interpret. This tool handles the %{noun} calculation %{context} so you can focus on what the result means for your routine. Pair the output with your own observations — energy levels, sleep, performance — to build a fuller picture than any single metric provides.",
        "Quick estimates beat vague guesses when you're tuning a fitness or nutrition plan. Enter your details and this calculator returns your %{noun} %{context} along with the reference ranges that make the number meaningful. Use the result as a starting point for discussion with a coach or healthcare professional rather than a final verdict."
      ],
      "construction" => [
        "Accurate %{noun} estimation %{context} prevents wasted materials and unexpected project delays. Whether you are a homeowner tackling a weekend project or a contractor preparing a bid, getting the quantities right from the start saves both time and money. This calculator determines exactly how much %{noun} you need %{context}, factoring in standard waste allowances so you can order with confidence.",
        "Underestimating materials means an extra trip to the supplier; overestimating means money sitting in your garage. This %{noun} calculator splits the difference by computing the realistic quantity %{context}, with industry-standard waste built in. Use it before requesting quotes so you can compare bids on a like-for-like basis instead of trusting each contractor's own math.",
        "Every construction project lives or dies on the take-off. This calculator works out %{noun} %{context} from your dimensions in seconds, replacing the back-of-envelope sketches that produce both shortages and excess. Conservative waste factors are included by default — adjust your order up if your project involves complex cuts, heavy patterns, or installer inexperience.",
        "Whether the project is a small DIY job or part of a larger renovation, the %{noun} calculation %{context} is the same standard formula contractors have used for decades. This tool runs it for you and presents the result in the units you actually order in, so the gap between calculation and purchase order disappears."
      ],
      "everyday" => [
        "Calculating %{noun} %{context} takes the guesswork out of everyday decisions. Instead of relying on rough estimates or mental math, this tool gives you precise figures in seconds. Enter your numbers below and get instant results for %{noun} %{context}. The calculator updates as you type, so you can experiment with different scenarios and find the answer that fits your situation.",
        "Some calculations come up often enough that doing them in your head is fine — until you need an exact answer. This %{noun} calculator handles the figures %{context} on demand, with no app to install and no account to create. Bookmark it for the next time the same question lands on your desk.",
        "Everyday math doesn't have to be tedious. Drop your numbers into this %{noun} calculator and the result %{context} appears immediately, formatted in the units you actually use. Adjust any field to see how the answer changes — handy for comparing options or planning around a constraint you can't change.",
        "Small calculations add up to better decisions when you take a moment to run them. This tool computes %{noun} %{context} instantly so you can move on with confidence rather than a hopeful guess. Each input field accepts the kind of number you're likely to have on hand — no unit conversion gymnastics required."
      ],
      "math" => [
        "Computing %{noun} %{context} is a fundamental mathematical operation used across science, engineering, and daily life. This calculator handles the computation instantly, showing you the result along with the formula and intermediate steps. Whether you are solving homework problems, verifying professional calculations, or exploring mathematical concepts, you will get accurate results %{context} every time.",
        "Mathematics is most useful when the mechanics get out of the way. This calculator handles %{noun} %{context} the moment you supply the inputs, then displays the formula it applied so you can audit the work or learn the underlying relationship. Enter values, read the answer, and dig into the steps if you want to see how the result was derived.",
        "Whether you're double-checking a homework answer or working through a real-world problem, the %{noun} calculation %{context} should be reliable, fast, and traceable. This tool delivers all three. Inputs are validated for sanity, the formula is shown alongside the result, and edge cases (division by zero, negatives where they don't make sense) are handled with clear messages instead of silent failures.",
        "Manual arithmetic is error-prone in proportion to how much it matters that you get the answer right. This %{noun} calculator removes that risk %{context}, applying the standard formula precisely each time. Use it for verification, exploration, or as the final step in a longer calculation chain."
      ],
      "physics" => [
        "Converting and calculating %{noun} %{context} is essential for engineering, science coursework, and practical applications. This tool performs the calculation instantly using standard formulas and conversion factors. Enter your values below to get precise results %{context}, complete with the relevant equations so you can verify the math independently.",
        "Physics problems usually fail at the unit step, not the formula step. This %{noun} calculator handles both: the computation %{context} and the dimensional analysis behind it. Enter your numbers in whichever unit system you prefer and the result is presented with proper units, ready to plug into the next step of your work.",
        "From textbook problems to back-of-envelope engineering checks, the %{noun} calculation %{context} comes up often enough to deserve a dedicated tool. This calculator applies the textbook equation, displays it for transparency, and handles common unit conversions automatically. Use it to confirm a manual calculation or as a quick reference when you need a number fast.",
        "Accurate physics depends on consistent units and correct constants — both of which this calculator handles for you. Provide your input values and the tool returns %{noun} %{context} with the formula clearly shown, so you can trace exactly how the answer was reached. Suitable for coursework, lab reports, and applied engineering checks."
      ]
    }.freeze

    # Each slot is a bank of 3 question/answer variants. The variant chosen for
    # a given page is deterministic on base_key+pattern_key, so the five
    # generic FAQs vary across hundreds of auto-generated pages instead of
    # being word-for-word identical.
    GENERIC_FAQ_SLOTS = [
      # Slot 1 — how to use
      [
        {
          question: "How do I calculate %{noun} %{context}?",
          answer: "Enter your values into the calculator fields above and the result appears instantly. The calculator uses standard formulas to compute %{noun} %{context} accurately. All you need are the basic input values — the tool handles the math automatically and updates results as you type, so you can experiment with different numbers without reloading the page."
        },
        {
          question: "What's the easiest way to work out %{noun} %{context}?",
          answer: "The simplest path is to fill in the fields above with the numbers you have on hand. The result is computed and displayed below as soon as the inputs are valid, and any change updates the figure live. There's no submit button to remember and no math to do yourself — the calculator does the work in the browser."
        },
        {
          question: "Where do I start when calculating %{noun} %{context}?",
          answer: "Begin by entering whichever input you already know with confidence. The calculator will display partial results as you go and update the final figure once every required field is filled. If you don't have an exact value for one input, try a reasonable estimate to see how sensitive the result is to that variable."
        }
      ],
      # Slot 2 — accuracy
      [
        {
          question: "How accurate is the %{noun} %{label} calculator?",
          answer: "The calculator uses the same mathematical formulas employed by professionals in the %{category} field. Results are accurate to the precision of your inputs — the better your input data, the more reliable the output. For critical decisions, cross-reference the result with a professional consultation or a second calculation method to confirm."
        },
        {
          question: "Can I trust the result this calculator produces?",
          answer: "The underlying formulas are standard and widely accepted. Accuracy of the displayed number is bounded by the accuracy of what you enter — round inputs lead to rounded outputs. For high-stakes decisions, treat the result as a strong starting estimate and verify against a second source or professional advice rather than as a final answer."
        },
        {
          question: "How precise are the numbers shown by this tool?",
          answer: "Internally the calculation runs in full floating-point precision; displayed values are rounded to the nearest sensible unit for readability. The output is as exact as the inputs allow. Where industry conventions assume specific waste factors, rounding rules, or fee structures, those are applied the same way a professional in the %{category} field would apply them."
        }
      ],
      # Slot 3 — required inputs
      [
        {
          question: "What inputs do I need for this calculator?",
          answer: "You need the standard measurements relevant to %{noun} %{context}. The input fields are labeled clearly with units and example values as placeholders. If you are unsure about any value, hover over the field label for guidance, or start with the placeholder values to see a sample result before entering your own numbers."
        },
        {
          question: "What information should I have ready before I start?",
          answer: "Have the basic figures for %{noun} %{context} at hand — the input labels above tell you exactly which numbers are required and which units they expect. Placeholder values demonstrate a typical example, so if a field looks unfamiliar, the placeholder shows the kind of value the calculator wants."
        },
        {
          question: "Which fields are required to get a result?",
          answer: "Only the fields marked as primary inputs are strictly required. Optional fields refine the calculation but are not necessary for a usable answer. If you skip an optional input, the calculator falls back on a sensible default and notes the assumption alongside the result."
        }
      ],
      # Slot 4 — device support
      [
        {
          question: "Can I use this calculator on my phone?",
          answer: "Yes, this calculator is fully responsive and works on smartphones, tablets, and desktop computers. The input fields and results are optimized for touch screens with appropriately sized tap targets. Results update in real time on all devices without requiring any app download or installation."
        },
        {
          question: "Does this work on mobile browsers?",
          answer: "It does. The layout adapts to the screen size of any modern phone or tablet, the inputs use the appropriate mobile keyboards (numeric pads for numbers, for example), and the result is positioned where you can see it without excessive scrolling. No app, no install — just the browser you already have."
        },
        {
          question: "Will the calculator run offline or on slow connections?",
          answer: "Once the page is loaded, the calculation runs entirely in your browser, so no further network requests are needed to update the result. On a slow connection the initial page load is the only delay; after that, every input change is processed instantly on your device."
        }
      ],
      # Slot 5 — cost / privacy
      [
        {
          question: "Is this %{noun} calculator free to use?",
          answer: "Yes, this calculator is completely free with no sign-up, no account creation, and no usage limits. You can calculate %{noun} %{context} as many times as you need. The tool runs entirely in your browser — no data is sent to any server, and your inputs are not stored or tracked."
        },
        {
          question: "Are there limits on how often I can use this tool?",
          answer: "No usage limits apply. You can run as many calculations as you like, in any session, without an account. Inputs are processed in your browser rather than sent to a server, so there is nothing for us to throttle and nothing for us to log."
        },
        {
          question: "Do I need to create an account to see results?",
          answer: "No account is needed. Open the page, enter your numbers, and the result appears — that's the entire workflow. The tool is funded by ads on the surrounding page, not by collecting your data, so the calculation itself stays private to your browser session."
        }
      ]
    ].freeze

    class << self
      def build_page(base_key, base_config, pattern_key, pattern_config)
        calc_name = base_config[:noun]
        calc_verb = base_config[:verb]
        category = base_config[:category]
        label = pattern_config[:label]
        context = pattern_config[:context]
        suffix = pattern_config[:suffix]
        slug = "#{base_key}-#{suffix}-calculator"
        full_name = "#{calc_name.split.map(&:capitalize).join(' ')} #{label}"

        variant_seed = Digest::MD5.hexdigest("#{base_key}-#{pattern_key}").to_i(16)
        intro = build_intro(calc_name, label, context, category, variant_seed)
        how_it_works = build_how_it_works(calc_name, label, context, category)
        how_it_works_text = how_it_works[:paragraphs].join(" ")

        {
          slug: slug,
          route_name: "programmatic_#{slug.tr('-', '_')}",
          title: truncate_title("#{full_name} Calculator - Free Tool"),
          h1: "#{full_name} Calculator",
          meta_description: truncate_meta("Calculate #{calc_name} #{context}. Free instant results with no sign-up required. Enter your numbers and get accurate estimates immediately."),
          intro: intro,
          how_it_works: how_it_works,
          example: build_example(calc_name, label, context, category),
          tips: build_tips(calc_name, label, context, category),
          faq: build_faq(calc_name, label, context, category, base_key, pattern_key),
          related_slugs: [],  # filled in by Registry after all pages are built
          base_calculator_slug: "#{base_key}-calculator",
          base_calculator_path: find_base_path(base_key, category),
          content_hash: Digest::MD5.hexdigest("#{slug}#{intro}#{how_it_works_text}")[0..7]
        }
      end

      private

      def truncate_title(title)
        title.length <= 60 ? title : title[0..56] + "..."
      end

      def truncate_meta(desc)
        desc.length <= 155 ? desc : desc[0..151] + "..."
      end

      def find_base_path(base_key, category)
        method_name = base_key.tr("-", "_")
        :"#{category}_#{method_name}_path"
      end

      # Returns one intro from a category-specific bank, deterministically
      # selected by variant_seed. Multiple variants per category prevent
      # near-duplicate intros across hundreds of auto-generated pages.
      def build_intro(noun, label, context, category, variant_seed)
        bank = INTRO_VARIANTS[category] || INTRO_VARIANTS["everyday"]
        template = bank[variant_seed % bank.size]
        format(template, noun: noun, context: context, label: label)
      end

      def build_how_it_works(noun, label, context, category)
        {
          heading: "How the #{noun.split.map(&:capitalize).join(' ')} #{label} Calculator Works",
          paragraphs: how_it_works_paragraphs(noun, label, context, category)
        }
      end

      def how_it_works_paragraphs(noun, label, context, category)
        p1 = case category
        when "finance"
          "This calculator uses standard financial formulas to determine your #{noun} #{context}. Enter the key variables — typically amounts, rates, and time periods — and the tool applies the appropriate equation to produce your result. All calculations follow the same mathematical models used by banks, financial advisors, and accounting software, ensuring your estimates are professionally accurate."
        when "health"
          "The calculator applies established health science formulas to estimate your #{noun} #{context}. It factors in your personal measurements and characteristics to produce results tailored to your individual profile. The underlying equations are the same ones used in clinical nutrition, sports science, and medical practice, adapted here for quick self-assessment."
        when "construction"
          "The calculator works by taking your project dimensions and applying standard material coverage rates to determine the #{noun} you need #{context}. Industry-standard waste factors are included automatically — typically 5-10% for most materials — so the estimate accounts for cuts, breakage, and fitting losses that occur in real-world construction."
        when "math"
          "This calculator applies the standard mathematical formula for #{noun} #{context}. Enter your values and the tool computes the result using the exact same operations you would perform by hand, but without the risk of arithmetic errors. The formula is displayed alongside the result so you can follow the logic and learn the underlying mathematics."
        when "physics"
          "This tool uses established physics equations and conversion constants to calculate #{noun} #{context}. The calculations follow internationally recognized standards, using SI units as the base with automatic conversion to other unit systems. Results are computed to appropriate significant figures for scientific and engineering accuracy."
        else
          "Enter your values into the fields below and the calculator instantly computes your #{noun} #{context}. Results update in real time as you type, allowing you to experiment with different numbers and scenarios without clicking any buttons. The underlying formulas are standard, widely-used equations that produce accurate results for typical use cases."
        end

        p2 = case category
        when "finance"
          "The results include not just the primary figure but also related metrics that help you understand the full financial picture. Small changes in inputs — even a fraction of a percentage point in an interest rate or a few months in a time period — can significantly affect the outcome. Use the real-time updating to experiment with different scenarios and see how each variable impacts your #{noun}."
        when "health"
          "Keep in mind that calculator results are estimates based on population-level research data. Individual variation is normal — factors like genetics, medication, hydration status, and measurement precision all introduce variability. Use the result as a starting point for discussion with healthcare professionals rather than as a definitive medical assessment."
        when "construction"
          "Material quantities from this calculator give you a solid ordering baseline, but always verify measurements on-site before placing your order. Real-world conditions — uneven surfaces, structural obstructions, pattern matching, and local building code requirements — can affect the actual amount needed. Measure twice, order once, and keep your receipt for returns."
        when "math"
          "The calculator handles edge cases and special conditions automatically. For example, division by zero returns an error message rather than crashing, and very large or very small numbers are displayed in scientific notation for readability. If your input falls outside the valid range for the formula, the tool explains what went wrong and what values are acceptable."
        when "physics"
          "All results are displayed with appropriate units and can be converted between common unit systems. The calculator handles the dimensional analysis automatically, so you can mix input units and still get a correct result. Hover over or tap any result to see the formula that was applied, making this tool useful for both quick answers and educational purposes."
        else
          "The tool handles both simple and complex scenarios. Start with the basic inputs to get a quick answer, or fill in the optional fields for a more detailed calculation. Whether you need a rough estimate or a precise figure, the calculator adapts to the level of detail you provide. Results are formatted for easy reading and can be copied to your clipboard."
        end

        p3 = "For the most reliable results #{context}, use accurate input values rather than rough estimates. " \
             "The calculator's output is only as good as the numbers you enter. If you are unsure about a particular value, " \
             "try running the calculation with both a conservative and an optimistic estimate to see the range of possible outcomes. " \
             "This sensitivity analysis approach helps you make decisions even when some inputs are uncertain."

        [ p1, p2, p3 ]
      end

      def build_example(noun, label, context, category)
        specific = pattern_example_scenario(noun, label, context, category)
        {
          heading: "Example: #{noun.split.map(&:capitalize).join(' ')} #{label}",
          scenario: specific[:scenario],
          steps: specific[:steps]
        }
      end

      def pattern_example_scenario(noun, label, context, category)
        case category
        when "finance"
          {
            scenario: "Let's walk through a real example of calculating #{noun} #{context}. Suppose you have a $250,000 amount at 6% annual interest over 30 years.",
            steps: [
              "Enter $250,000 as the principal or total amount in the first field.",
              "Set the interest rate to 6% and the time period to 30 years.",
              "The calculator computes your #{noun} #{context} instantly, showing the result below the inputs.",
              "Try changing the rate to 5.5% to see how a half-point decrease affects your #{noun} — the difference may surprise you."
            ]
          }
        when "health"
          {
            scenario: "Here's a practical example: a 30-year-old, 5'10\" (178 cm), 165 lb (75 kg) individual calculating #{noun} #{context}.",
            steps: [
              "Enter age (30), height (178 cm or 5'10\"), and weight (75 kg or 165 lbs).",
              "Select the appropriate options from the dropdowns (gender, activity level).",
              "Review your #{noun} result #{context} — the calculator shows your personalized estimate.",
              "Compare with the reference ranges displayed alongside your result to see where you fall."
            ]
          }
        when "construction"
          {
            scenario: "Consider a 12 ft x 14 ft room (168 square feet) where you need to calculate #{noun} #{context}.",
            steps: [
              "Enter the room dimensions: 12 feet length and 14 feet width (168 sq ft total area).",
              "Add any relevant specifications like depth, height, or material type.",
              "The calculator shows you need approximately the right amount of #{noun} #{context}, including a 10% waste factor.",
              "Use this quantity to request quotes from suppliers or calculate your materials budget."
            ]
          }
        when "math"
          {
            scenario: "Here is a worked example: suppose you need to calculate #{noun} #{context} using the values 48 and 12.",
            steps: [
              "Enter 48 as the primary value in the first input field.",
              "Enter 12 as the secondary value in the second field.",
              "The calculator applies the formula and displays the result immediately — check the formula shown below to verify.",
              "Modify either input to explore how changes affect the outcome, for example try 96 and 24."
            ]
          }
        when "physics"
          {
            scenario: "Let's say you need to calculate #{noun} #{context} for an object with a mass of 5 kg and a velocity of 10 m/s.",
            steps: [
              "Enter 5 kg as the mass and 10 m/s as the velocity in the appropriate fields.",
              "The calculator applies the relevant physics equation and displays the result with proper units.",
              "Read the result in your preferred unit system — toggle between metric and imperial if available.",
              "Use the result for further calculations or compare with a different set of measurements."
            ]
          }
        else
          {
            scenario: "Here is a practical scenario for calculating #{noun} #{context}.",
            steps: [
              "Enter your primary value into the first input field.",
              "Fill in any secondary values (rates, quantities, or specifications).",
              "Review your #{noun} #{context} — the result appears instantly.",
              "Adjust inputs to compare different scenarios side by side."
            ]
          }
        end
      end

      def build_tips(noun, label, context, category)
        category_tips = {
          "finance" => [
            "Run calculations with both optimistic and conservative estimates to understand your range of possible outcomes before making financial commitments.",
            "Remember that #{noun} calculations #{context} do not account for inflation, taxes, or fees unless those are explicitly included as inputs.",
            "Save or screenshot your results for comparison when evaluating multiple financial options side by side.",
            "Revisit your calculations periodically as rates, prices, and your personal financial situation change over time."
          ],
          "health" => [
            "Take measurements at the same time of day for consistency, as body metrics can fluctuate throughout the day due to hydration and food intake.",
            "Use these results as a general guideline and discuss significant changes with your healthcare provider before adjusting your routine.",
            "Track your #{noun} over time to identify trends rather than reacting to any single calculation result.",
            "Individual variation is normal — the calculator provides evidence-based estimates, not exact predictions for every person."
          ],
          "construction" => [
            "Always add 5-10% extra to your calculated #{noun} #{context} to account for cuts, waste, and fitting adjustments during installation.",
            "Verify all measurements on-site before ordering materials — plans and estimates can differ from actual conditions.",
            "Check local building codes for minimum requirements that may affect the quantity or specification of materials needed.",
            "Buy materials from the same production batch or lot when possible to ensure consistent color and quality across your project."
          ],
          "everyday" => [
            "Double-check your input units (miles vs kilometers, gallons vs liters) to ensure the result matches your intended measurement system.",
            "Bookmark this calculator for quick access whenever you need to recalculate #{noun} #{context}.",
            "Use the results as a starting point for budgeting — actual costs may vary based on local prices and conditions.",
            "Share your calculation results easily using the copy or share buttons below the calculator."
          ],
          "math" => [
            "Verify your result by working the problem in reverse — plug the answer back into the original equation to confirm it holds.",
            "Pay attention to units and ensure all inputs use the same unit system before calculating.",
            "For complex problems, break them into smaller steps and calculate each part separately before combining.",
            "Use the formula displayed with the result to understand the mathematical relationship between your inputs and the answer."
          ],
          "physics" => [
            "Ensure all input values use consistent units — mixing metric and imperial without conversion leads to incorrect results.",
            "For real-world applications, account for factors the simplified formula may not include, such as friction, air resistance, or material impurities.",
            "Record your calculation parameters alongside results so you can reproduce or verify the computation later.",
            "When comparing results to experimental measurements, expect some deviation due to idealized assumptions in the formulas."
          ]
        }
        category_tips[category] || category_tips["everyday"]
      end

      def build_faq(noun, label, context, category, base_key, pattern_key)
        seed = Digest::MD5.hexdigest("#{base_key}-#{pattern_key}").to_i(16)

        faqs = GENERIC_FAQ_SLOTS.map do |slot|
          variant = slot[seed % slot.size]
          {
            question: format(variant[:question], noun: noun, context: context, label: label.downcase, category: category),
            answer: format(variant[:answer], noun: noun, context: context, label: label.downcase, category: category)
          }
        end

        faqs.concat(pattern_specific_faqs(noun, label, context, pattern_key))
        faqs
      end

      def pattern_specific_faqs(noun, label, context, pattern_key)
        key = pattern_key.to_s

        if key.start_with?("per_")
          unit = key.sub("per_", "").tr("_", " ")
          [
            {
              question: "How do I convert #{noun} to a per-#{unit} rate?",
              answer: "Divide the total #{noun} by the number of #{unit}s to get the per-#{unit} rate. This calculator handles the conversion automatically — enter your total figures and the tool computes the per-#{unit} breakdown instantly."
            },
            {
              question: "Why is per-#{unit} #{noun} useful to track?",
              answer: "Tracking #{noun} per #{unit} lets you compare costs across different scenarios on an equal basis. It normalizes the data so you can make apples-to-apples comparisons regardless of different quantities or time periods."
            }
          ]
        elsif key.start_with?("for_")
          audience = key.sub("for_", "").tr("_", " ")
          [
            {
              question: "Why is the #{noun} calculation different for #{audience}?",
              answer: "#{audience.capitalize} have specific considerations that affect #{noun} calculations. Standard formulas may not account for #{audience}-specific factors, which is why this specialized calculator adjusts the computation #{context} to provide more relevant results."
            },
            {
              question: "Can #{audience} use the standard #{noun} calculator instead?",
              answer: "You can use the standard calculator as a starting point, but this #{audience}-specific version applies adjustments that make the results more applicable to your situation. The specialized calculation accounts for factors that the general calculator doesn't include."
            }
          ]
        elsif key.include?("vs") || key.include?("comparison")
          [
            {
              question: "What are the key differences being compared?",
              answer: "This calculator compares the relevant metrics side by side so you can evaluate both options objectively. Enter the same base values for each scenario and the calculator highlights the differences in cost, duration, or outcome."
            }
          ]
        else
          # Default: add one pattern-specific FAQ
          [
            {
              question: "When should I use the #{label.downcase} calculation specifically?",
              answer: "Use this specific calculation when you need to #{context}. The #{label.downcase} variant focuses on this particular aspect of #{noun}, providing more targeted results than the general calculator."
            }
          ]
        end
      end
    end
  end
end
