module ProgrammaticSeo
  module ContentTemplates
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

        {
          slug: slug,
          route_name: "programmatic_#{slug.tr('-', '_')}",
          title: truncate_title("#{full_name} Calculator - Free Tool"),
          h1: "#{full_name} Calculator",
          meta_description: truncate_meta("Calculate #{calc_name} #{context}. Free instant results with no sign-up required. Enter your numbers and get accurate estimates immediately."),
          intro: build_intro(calc_name, label, context, category),
          how_it_works: build_how_it_works(calc_name, label, context, category),
          example: build_example(calc_name, label, context, category),
          tips: build_tips(calc_name, label, context, category),
          faq: build_faq(calc_name, label, context, category, base_key, pattern_key),
          related_slugs: [],  # filled in by Registry after all pages are built
          base_calculator_slug: "#{base_key}-calculator",
          base_calculator_path: find_base_path(base_key, category)
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

      def build_intro(noun, label, context, category)
        intros = {
          "finance" => "Understanding your #{noun} #{context} is a critical step in making informed financial decisions. Whether you are planning a major purchase, evaluating an investment, or budgeting for the future, having precise numbers helps you compare options and avoid costly surprises. This calculator provides instant #{noun} estimates #{context}, giving you the clarity you need to move forward with confidence. Simply enter your figures and see results update in real time.",
          "health" => "Knowing your #{noun} #{context} helps you make better decisions about your health and fitness routine. Everyone's body is different, and generic recommendations often miss important nuances. This calculator tailors the standard #{noun} calculation #{context}, providing personalized results that account for your specific situation. Enter your details below to get science-based estimates that support your wellness goals.",
          "construction" => "Accurate #{noun} estimation #{context} prevents wasted materials and unexpected project delays. Whether you are a homeowner tackling a weekend project or a contractor preparing a bid, getting the quantities right from the start saves both time and money. This calculator determines exactly how much #{noun} you need #{context}, factoring in standard waste allowances so you can order with confidence.",
          "everyday" => "Calculating #{noun} #{context} takes the guesswork out of everyday decisions. Instead of relying on rough estimates or mental math, this tool gives you precise figures in seconds. Enter your numbers below and get instant results for #{noun} #{context}. The calculator updates as you type, so you can experiment with different scenarios and find the answer that fits your situation.",
          "math" => "Computing #{noun} #{context} is a fundamental mathematical operation used across science, engineering, and daily life. This calculator handles the computation instantly, showing you the result along with the formula and intermediate steps. Whether you are solving homework problems, verifying professional calculations, or exploring mathematical concepts, you will get accurate results #{context} every time.",
          "physics" => "Converting and calculating #{noun} #{context} is essential for engineering, science coursework, and practical applications. This tool performs the calculation instantly using standard formulas and conversion factors. Enter your values below to get precise results #{context}, complete with the relevant equations so you can verify the math independently."
        }
        intros[category] || intros["everyday"]
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

        [p1, p2, p3]
      end

      def build_example(noun, label, context, category)
        {
          heading: "Example: #{noun.split.map(&:capitalize).join(' ')} #{label}",
          scenario: "Here is a typical scenario for calculating #{noun} #{context}.",
          steps: example_steps(noun, label, context, category)
        }
      end

      def example_steps(noun, label, context, category)
        case category
        when "finance"
          [
            "Enter the principal amount or total value into the first field",
            "Set the rate, percentage, or time period in the corresponding fields",
            "The calculator instantly shows your #{noun} #{context}",
            "Adjust any input to compare different financial scenarios side by side"
          ]
        when "health"
          [
            "Enter your basic measurements (weight, height, age) in the input fields",
            "Select any applicable options (gender, activity level, goals) from the dropdowns",
            "Review your personalized #{noun} result #{context}",
            "Compare with standard reference ranges shown alongside your result"
          ]
        when "construction"
          [
            "Measure your project area and enter length, width, and depth or height",
            "The calculator converts your measurements and applies coverage rates",
            "Review the total #{noun} needed #{context}, including waste factor",
            "Use the result to determine how many units, bags, or packages to order"
          ]
        when "math"
          [
            "Enter your known values into the input fields",
            "The calculator applies the formula and displays the result immediately",
            "Check the formula shown below the result to verify the calculation method",
            "Modify any input to explore how changes affect the outcome"
          ]
        when "physics"
          [
            "Enter your known measurements with the appropriate units",
            "The calculator applies the relevant physics equation automatically",
            "Read the result in your preferred unit system",
            "Use the result for further calculations or unit comparisons"
          ]
        else
          [
            "Enter the relevant numbers into the input fields provided",
            "Results appear instantly below the inputs — no button click needed",
            "Review your #{noun} #{context}",
            "Try different values to compare scenarios and find the best option"
          ]
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
        [
          {
            question: "How do I calculate #{noun} #{context}?",
            answer: "Enter your values into the calculator fields above and the result appears instantly. The calculator uses standard formulas to compute #{noun} #{context} accurately. All you need are the basic input values — the tool handles the math automatically and updates results as you type, so you can experiment with different numbers without reloading the page."
          },
          {
            question: "How accurate is the #{noun} #{label.downcase} calculator?",
            answer: "The calculator uses the same mathematical formulas employed by professionals in the #{category} field. Results are accurate to the precision of your inputs — the better your input data, the more reliable the output. For critical decisions, cross-reference the result with a professional consultation or a second calculation method to confirm."
          },
          {
            question: "What inputs do I need for this calculator?",
            answer: "You need the standard measurements relevant to #{noun} #{context}. The input fields are labeled clearly with units and example values as placeholders. If you are unsure about any value, hover over the field label for guidance, or start with the placeholder values to see a sample result before entering your own numbers."
          },
          {
            question: "Can I use this calculator on my phone?",
            answer: "Yes, this calculator is fully responsive and works on smartphones, tablets, and desktop computers. The input fields and results are optimized for touch screens with appropriately sized tap targets. Results update in real time on all devices without requiring any app download or installation."
          },
          {
            question: "Is this #{noun} calculator free to use?",
            answer: "Yes, this calculator is completely free with no sign-up, no account creation, and no usage limits. You can calculate #{noun} #{context} as many times as you need. The tool runs entirely in your browser — no data is sent to any server, and your inputs are not stored or tracked."
          }
        ]
      end
    end
  end
end
