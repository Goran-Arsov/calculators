module ProgrammaticSeo
  module Content
    module CompoundInterest
      DEFINITION = {
        base_key: "compound_interest",
        category: "finance",
        stimulus_controller: "compound-interest-calculator",
        form_partial: "programmatic/forms/compound_interest",
        icon_path: "M13 7h8m0 0v8m0-8l-8 8-4-4-6 6",
        expansions: [
          {
            slug: "daily-compound-interest-calculator",
            route_name: "programmatic_daily_compound_interest",
            title: "Daily Compound Interest Calculator | CalcWise",
            h1: "Daily Compound Interest Calculator",
            meta_description: "Calculate compound interest with daily compounding. See how your savings or investments grow when interest is added every single day.",
            intro: "Daily compounding is the most frequent compounding interval offered by banks and financial " \
                   "institutions, and it can make a meaningful difference in how fast your money grows compared to " \
                   "monthly or annual compounding. This calculator shows you exactly how much your principal earns " \
                   "when interest is calculated and added to your balance every day of the year. Enter your starting " \
                   "amount, annual interest rate, and time horizon to see the power of 365-times-per-year compounding.",
            how_it_works: {
              heading: "How Daily Compound Interest Works",
              paragraphs: [
                "Daily compounding divides your annual interest rate by 365 and applies that fraction to your " \
                "balance every day. Each day's interest is added to the principal, so the next day's calculation " \
                "uses a slightly larger base. Over time, this creates exponential growth because you earn interest " \
                "on previously earned interest. The formula is A = P(1 + r/365)^(365t), where P is principal, " \
                "r is the annual rate, and t is time in years.",
                "The difference between daily and monthly compounding is subtle for small balances and short " \
                "time periods but becomes significant for larger amounts held over many years. On a $100,000 " \
                "deposit at 5% APR over 10 years, daily compounding produces roughly $164,872 compared to " \
                "$164,701 with monthly compounding — a difference of about $171. At higher rates or longer " \
                "durations, the gap widens considerably.",
                "High-yield savings accounts, money market accounts, and many certificates of deposit use daily " \
                "compounding. When comparing financial products, look for the annual percentage yield (APY) rather " \
                "than the APR, because APY already accounts for the compounding frequency and gives you the true " \
                "effective return you will earn over a full year."
              ]
            },
            example: {
              heading: "Example: Daily Compounding on a Savings Account",
              scenario: "You deposit $25,000 into a high-yield savings account offering 4.5% APR with daily compounding.",
              steps: [
                "Enter $25,000 as the principal, 4.5% as the annual rate, and daily as the compounding frequency.",
                "After 1 year, your balance grows to approximately $25,1151 ($1,151 in interest earned).",
                "After 5 years with no additional deposits, the balance reaches approximately $31,182.",
                "The effective APY is 4.603%, slightly higher than the stated 4.5% APR due to daily compounding."
              ]
            },
            tips: [
              "When comparing savings accounts, focus on the APY rather than the APR because APY reflects the actual annual return after compounding is factored in.",
              "Daily compounding matters most for larger balances. On a $1,000 deposit, the difference between daily and monthly compounding is only a few cents per year.",
              "Reinvesting dividends from brokerage accounts creates a similar compounding effect even though stocks do not technically compound like bank deposits.",
              "Leave your money untouched as long as possible to maximize the compounding benefit, since withdrawals reset the base amount that earns future interest."
            ],
            faq: [
              {
                question: "What is the difference between daily and monthly compounding?",
                answer: "Daily compounding calculates and adds interest to your balance 365 times per year, while monthly " \
                        "compounding does so 12 times per year. Daily compounding produces slightly more interest because " \
                        "each day's earned interest immediately starts earning its own interest. The difference is typically " \
                        "small — a few basis points in effective yield — but it compounds over time and matters more for " \
                        "larger balances held over longer periods."
              },
              {
                question: "Do banks actually compound interest daily?",
                answer: "Many banks compound interest daily but only credit it to your account monthly or quarterly. The " \
                        "compounding still happens internally — the bank tracks your daily balance and applies the daily " \
                        "rate, accumulating interest that is then posted to your account at the crediting interval. The " \
                        "APY you earn reflects the daily compounding regardless of when the interest appears in your statement."
              },
              {
                question: "Is daily compounding better than continuous compounding?",
                answer: "Continuous compounding is the theoretical maximum, but the difference from daily compounding is " \
                        "negligible in practice. On $100,000 at 5% for one year, continuous compounding yields $5,127.11 " \
                        "while daily compounding yields $5,126.75 — a difference of just 36 cents. No consumer financial " \
                        "product offers true continuous compounding, making daily the practical best option."
              },
              {
                question: "How does daily compounding affect credit card debt?",
                answer: "Credit card companies also use daily compounding on unpaid balances, which works against you " \
                        "as a borrower. At a 24% APR compounded daily, the effective annual rate is about 27.1%. " \
                        "This means carrying a balance costs you more than the stated rate suggests. Paying off credit " \
                        "card debt as quickly as possible is critical because daily compounding accelerates what you owe."
              }
            ],
            related_slugs: [
              "monthly-compound-interest-calculator",
              "compound-interest-with-contributions-calculator",
              "compound-vs-simple-interest-calculator"
            ],
            base_calculator_slug: "compound-interest-calculator",
            base_calculator_path: :finance_compound_interest_path
          },
          {
            slug: "monthly-compound-interest-calculator",
            route_name: "programmatic_monthly_compound_interest",
            title: "Monthly Compound Interest Calculator | CalcWise",
            h1: "Monthly Compound Interest Calculator",
            meta_description: "Calculate how your money grows with monthly compounding. See the month-by-month breakdown of interest earned and total balance over time.",
            intro: "Monthly compounding is one of the most common compounding frequencies used by banks, credit unions, " \
                   "and investment platforms. Interest is calculated on your balance once per month and added to the " \
                   "principal, so each subsequent month earns interest on a slightly larger sum. This calculator provides " \
                   "a clear month-by-month growth schedule so you can track exactly how your savings or investments " \
                   "build over time with the power of compound interest working twelve times per year.",
            how_it_works: {
              heading: "How Monthly Compound Interest Works",
              paragraphs: [
                "Monthly compounding divides the annual interest rate by 12 to determine the monthly rate, then " \
                "applies that rate to your current balance at the end of each month. The earned interest is added " \
                "to the principal immediately, increasing the base for the following month's calculation. The " \
                "formula is A = P(1 + r/12)^(12t), where P is the initial principal, r is the annual interest " \
                "rate as a decimal, and t is the number of years.",
                "The compounding effect accelerates over time. In the first year, most of your balance growth comes " \
                "from the original principal earning interest. By year five or ten, a significant portion of each " \
                "month's interest comes from previously earned interest rather than the original deposit. This " \
                "snowball effect is why starting to save early makes such a dramatic difference in long-term wealth.",
                "Monthly compounding is the standard for most savings accounts, CDs, and many loan calculations. " \
                "Understanding this frequency helps you accurately project savings milestones like reaching " \
                "$100,000 or building a retirement fund. It also helps you understand how loan interest accrues " \
                "on mortgages, auto loans, and student loans that use monthly compounding."
              ]
            },
            example: {
              heading: "Example: Monthly Compounding on a CD",
              scenario: "You invest $10,000 in a 3-year CD offering 5.0% APR with monthly compounding.",
              steps: [
                "Enter $10,000 as the principal, 5.0% as the annual rate, and 3 years as the duration.",
                "After month 1, you earn $41.67 in interest, bringing the balance to $10,041.67.",
                "After 12 months, the balance reaches approximately $10,512, earning $512 in the first year.",
                "After 36 months, the final balance is approximately $11,614, for a total return of $1,614 on your investment.",
                "The effective APY is 5.116%, reflecting the compounding benefit above the stated 5.0% APR."
              ]
            },
            tips: [
              "Set up automatic monthly transfers to your savings account so new deposits begin compounding immediately alongside your existing balance.",
              "Compare APYs rather than APRs when shopping for savings accounts, since APY accounts for the compounding frequency and shows your true annual return.",
              "Avoid withdrawing earned interest if possible, because removing it eliminates the compounding benefit and reduces your future growth significantly.",
              "Use a monthly compounding calculator to set realistic savings targets with specific dates, making your financial goals concrete and trackable."
            ],
            faq: [
              {
                question: "How much difference does monthly compounding make compared to annual?",
                answer: "On $50,000 at 6% for 10 years, annual compounding produces $89,542 while monthly compounding " \
                        "produces $90,970 — a difference of $1,428. The gap grows with higher rates, larger balances, " \
                        "and longer time periods. For a 30-year retirement horizon, monthly compounding can produce " \
                        "thousands more than annual compounding on the same deposit."
              },
              {
                question: "What types of accounts use monthly compounding?",
                answer: "Most savings accounts, money market accounts, and certificates of deposit use monthly or daily " \
                        "compounding. Many bonds pay interest semi-annually, which compounds less frequently. Brokerage " \
                        "accounts do not technically compound unless dividends are reinvested. Mortgage and auto loan " \
                        "interest is also typically calculated monthly."
              },
              {
                question: "Can I calculate monthly compounding with regular contributions?",
                answer: "Yes, the future value of a series formula extends the basic compound interest calculation to " \
                        "include regular monthly deposits. Each contribution begins compounding from its deposit date. " \
                        "Adding even modest monthly contributions dramatically increases the final balance because each " \
                        "new deposit starts earning compound interest immediately."
              },
              {
                question: "Why do some months earn more interest than others?",
                answer: "With monthly compounding, each month earns more interest than the previous month because the " \
                        "base balance grows. The first month's interest is calculated on the original principal, but " \
                        "subsequent months include previously earned interest in the calculation. This progressive " \
                        "increase is the essence of compound growth and why long holding periods are so powerful."
              }
            ],
            related_slugs: [
              "daily-compound-interest-calculator",
              "compound-interest-with-contributions-calculator",
              "money-doubling-time-calculator"
            ],
            base_calculator_slug: "compound-interest-calculator",
            base_calculator_path: :finance_compound_interest_path
          },
          {
            slug: "compound-interest-with-contributions-calculator",
            route_name: "programmatic_compound_interest_contributions",
            title: "Compound Interest Calculator with Monthly Contributions | CalcWise",
            h1: "Compound Interest with Monthly Contributions Calculator",
            meta_description: "Calculate compound interest with regular monthly deposits. See how consistent contributions supercharge your investment growth over time.",
            intro: "The real power of compound interest reveals itself when you combine it with regular monthly " \
                   "contributions. A single lump sum grows well on its own, but adding even a modest amount each " \
                   "month creates a dramatically steeper growth curve. This calculator shows you exactly how your " \
                   "wealth builds when you pair an initial investment with ongoing deposits, giving you a clear " \
                   "picture of how consistency and time work together to generate substantial returns.",
            how_it_works: {
              heading: "How Compound Interest with Contributions Works",
              paragraphs: [
                "The calculator combines two growth components: your initial principal compounding over time and " \
                "each monthly contribution compounding from its deposit date forward. The first deposit compounds " \
                "for the full duration, the second for one month less, and so on. The combined formula accounts " \
                "for both the lump sum future value and the future value of the annuity (the series of regular " \
                "payments), producing a total that is greater than either component alone.",
                "Monthly contributions have an outsized impact because of dollar-cost averaging into compound " \
                "growth. Even if you start with zero principal, contributing $500 per month at 7% annual return " \
                "grows to approximately $87,000 after 10 years — of which $27,000 is pure compound interest. " \
                "After 30 years, the same $500 monthly reaches roughly $607,000, with $427,000 coming from " \
                "compounding rather than your deposits.",
                "This calculator is essential for retirement planning, education savings, and any long-term goal " \
                "where you plan to save regularly. It answers the critical question of how much you need to " \
                "contribute each month to reach a specific target by a certain date, helping you reverse-engineer " \
                "a savings plan that aligns with your financial goals."
              ]
            },
            example: {
              heading: "Example: Retirement Savings with Monthly Contributions",
              scenario: "You start with $5,000 and contribute $300 per month at a 7% annual return for 25 years.",
              steps: [
                "Enter $5,000 as the initial principal, $300 as the monthly contribution, 7% annual rate, and 25 years.",
                "Your total contributions over 25 years: $5,000 + ($300 x 300 months) = $95,000 invested out of pocket.",
                "The calculator shows a final balance of approximately $248,000.",
                "Compound interest earned: roughly $153,000 — more than 1.6 times your total contributions.",
                "If you increase contributions to $500 per month, the final balance jumps to approximately $402,000."
              ]
            },
            tips: [
              "Start contributing as early as possible even if the amount is small. A 25-year-old saving $200 per month at 7% will have more at 65 than a 35-year-old saving $400 per month.",
              "Increase your monthly contribution by at least the rate of inflation each year to maintain real purchasing power growth in your savings.",
              "Automate your monthly contributions through direct deposit or automatic transfers so you never miss a month and the habit becomes effortless.",
              "Use employer 401(k) matching as a guaranteed return on top of compound interest. Contributing enough to capture the full match is the highest-return financial decision available."
            ],
            faq: [
              {
                question: "How much should I contribute monthly to reach $1 million?",
                answer: "The required monthly contribution depends on your starting amount, expected return, and time " \
                        "horizon. Starting from zero at a 7% annual return, you would need approximately $380 per month " \
                        "for 40 years, $820 per month for 30 years, or $2,100 per month for 20 years. Starting with a " \
                        "larger initial deposit reduces the monthly requirement proportionally."
              },
              {
                question: "Do contributions at the beginning or end of the month matter?",
                answer: "Contributing at the beginning of the month gives each deposit one extra month of compounding " \
                        "compared to end-of-month contributions. Over 30 years at 7%, this timing difference adds roughly " \
                        "0.6% to your final balance. While not dramatic, beginning-of-month contributions are slightly " \
                        "more advantageous and easy to implement through automatic transfers on the 1st."
              },
              {
                question: "Should I invest a lump sum or spread it out in monthly contributions?",
                answer: "Historically, investing a lump sum immediately outperforms spreading it over monthly contributions " \
                        "about two-thirds of the time because markets trend upward over long periods. However, monthly " \
                        "contributions reduce the risk of investing everything at a market peak. For money you already " \
                        "have, lump sum investing is statistically favored. For ongoing income, monthly contributions " \
                        "are the natural and effective approach."
              },
              {
                question: "How do I account for increasing contributions over time?",
                answer: "Many people increase their savings rate as their income grows. While this calculator uses a fixed " \
                        "monthly amount, you can model increasing contributions by running separate calculations for each " \
                        "phase. For example, calculate 5 years at $300 per month, then use that ending balance as the " \
                        "starting principal for the next 5 years at $500 per month, and so on."
              }
            ],
            related_slugs: [
              "monthly-compound-interest-calculator",
              "money-doubling-time-calculator",
              "daily-compound-interest-calculator"
            ],
            base_calculator_slug: "compound-interest-calculator",
            base_calculator_path: :finance_compound_interest_path
          },
          {
            slug: "money-doubling-time-calculator",
            route_name: "programmatic_money_doubling_time",
            title: "How Long to Double Your Money Calculator | CalcWise",
            h1: "Money Doubling Time Calculator",
            meta_description: "Calculate how long it takes to double your money at any interest rate. Uses the Rule of 72 and exact compound interest formula for precise results.",
            intro: "One of the most powerful concepts in personal finance is understanding how quickly your money can " \
                   "double through compound interest. This calculator uses both the Rule of 72 for a quick estimate " \
                   "and the exact compound interest formula for precision. Enter any interest rate to see how many " \
                   "years it takes for your investment to double, triple, or quadruple — giving you a tangible " \
                   "sense of what different returns mean for your long-term wealth.",
            how_it_works: {
              heading: "How Money Doubling Time Is Calculated",
              paragraphs: [
                "The Rule of 72 provides a quick mental estimate: divide 72 by the annual interest rate to get " \
                "the approximate doubling time in years. At 6%, money doubles in about 12 years (72 / 6 = 12). " \
                "At 8%, it takes roughly 9 years (72 / 8 = 9). This rule is remarkably accurate for rates between " \
                "4% and 12% and gives you an instant reference without needing a calculator.",
                "For exact results, the calculator uses the compound interest formula solved for time: " \
                "t = ln(2) / ln(1 + r/n), where r is the annual rate, n is the compounding frequency, and " \
                "ln is the natural logarithm. This formula accounts for the specific compounding interval and " \
                "produces a precise doubling time down to months and days rather than the rough estimate from " \
                "the Rule of 72.",
                "Understanding doubling time puts investment returns into a concrete, intuitive framework. " \
                "Instead of thinking abstractly about percentage returns, you can visualize your $50,000 " \
                "becoming $100,000, then $200,000, then $400,000 through successive doublings. Each doubling " \
                "adds more absolute dollars than the previous one, which is why compound growth accelerates " \
                "so dramatically in the later years of a long investment horizon."
              ]
            },
            example: {
              heading: "Example: Doubling Time at Different Rates",
              scenario: "You have $20,000 invested and want to know how long until it becomes $40,000 at various return rates.",
              steps: [
                "At 4% annual return: 72 / 4 = 18 years (exact: 17.7 years with monthly compounding).",
                "At 7% annual return: 72 / 7 = 10.3 years (exact: 10.0 years with monthly compounding).",
                "At 10% annual return: 72 / 10 = 7.2 years (exact: 7.0 years with monthly compounding).",
                "To quadruple your money, simply double the time since each doubling is a multiplicative step.",
                "At 7%, your $20,000 becomes $80,000 in roughly 20 years through two successive doublings."
              ]
            },
            tips: [
              "Use the Rule of 72 during financial conversations for quick estimates: at 8% your money doubles every 9 years, which means three doublings in 27 years — an 8x return.",
              "Even a 1% difference in annual return significantly changes doubling time. At 6% money doubles in 12 years, but at 7% it doubles in about 10 years — two years faster.",
              "Factor in inflation when calculating real doubling time. If your investments earn 7% and inflation is 3%, your real return is about 4%, doubling purchasing power every 18 years.",
              "Remember that the doubling time assumes reinvested returns. Withdrawing interest or dividends prevents compounding and extends the time needed to double your principal."
            ],
            faq: [
              {
                question: "What is the Rule of 72?",
                answer: "The Rule of 72 is a mental math shortcut for estimating how long an investment takes to double " \
                        "at a given annual rate of return. Simply divide 72 by the interest rate. At 6%, money doubles " \
                        "in approximately 12 years. The rule works because 72 is divisible by many common numbers and " \
                        "closely approximates the exact logarithmic calculation for rates between 4% and 12%."
              },
              {
                question: "How accurate is the Rule of 72?",
                answer: "The Rule of 72 is accurate within about 1% for interest rates between 4% and 12% with annual " \
                        "compounding. At very low rates below 4% or very high rates above 15%, the estimate becomes " \
                        "less precise. For rates above 20%, the Rule of 69.3 provides better approximations. For most " \
                        "practical investment and savings scenarios, the Rule of 72 is sufficiently accurate for quick " \
                        "decision-making."
              },
              {
                question: "How long does it take to double money in a savings account?",
                answer: "At current high-yield savings account rates of 4% to 5%, money doubles in approximately 14 to " \
                        "18 years. At a traditional savings account rate of 0.5%, doubling takes about 144 years. This " \
                        "stark contrast illustrates why choosing a high-yield savings account matters enormously for " \
                        "long-term savings, even though the rate difference seems small on a monthly basis."
              },
              {
                question: "Can I use the Rule of 72 for debt growth?",
                answer: "Yes, the Rule of 72 applies equally to debt. Credit card debt at 24% APR doubles in just 3 " \
                        "years (72 / 24 = 3) if no payments are made. This makes the rule a powerful tool for " \
                        "understanding how quickly unpaid debt can spiral. It underscores why paying off high-interest " \
                        "debt should take priority over low-return savings."
              }
            ],
            related_slugs: [
              "compound-interest-with-contributions-calculator",
              "daily-compound-interest-calculator",
              "compound-vs-simple-interest-calculator"
            ],
            base_calculator_slug: "compound-interest-calculator",
            base_calculator_path: :finance_compound_interest_path
          },
          {
            slug: "compound-vs-simple-interest-calculator",
            route_name: "programmatic_compound_vs_simple_interest",
            title: "Compound Interest vs Simple Interest Calculator | CalcWise",
            h1: "Compound Interest vs Simple Interest Calculator",
            meta_description: "Compare compound and simple interest side by side. See how much more you earn or owe with compounding versus flat simple interest over any time period.",
            intro: "Simple interest and compound interest produce very different outcomes over time, yet many people " \
                   "confuse the two or underestimate the gap between them. This calculator shows both calculations " \
                   "side by side for the same principal, rate, and duration so you can see exactly how much more " \
                   "compound interest generates for savers — or how much more it costs borrowers. Understanding " \
                   "this difference is fundamental to making informed decisions about savings, investments, and loans.",
            how_it_works: {
              heading: "How Compound and Simple Interest Differ",
              paragraphs: [
                "Simple interest is calculated only on the original principal amount. The formula is I = P x r x t, " \
                "where P is principal, r is the annual rate, and t is time in years. A $10,000 deposit at 5% simple " \
                "interest earns exactly $500 every year regardless of how long it is held. The total interest after " \
                "10 years is $5,000, and after 20 years is $10,000 — growth is perfectly linear.",
                "Compound interest, by contrast, calculates interest on the principal plus all previously earned " \
                "interest. The same $10,000 at 5% compounded annually earns $500 in year one but $525 in year two " \
                "(5% of $10,500), $551.25 in year three, and so on. After 10 years the total interest is $6,289 " \
                "rather than $5,000, and after 20 years it is $16,533 rather than $10,000. The gap accelerates " \
                "with each passing year.",
                "This calculator displays both growth curves on the same timeline, making the exponential nature " \
                "of compound interest visually obvious. It also shows the exact dollar difference at each milestone " \
                "so you can quantify the compounding advantage. For borrowers, this comparison reveals why compound " \
                "interest loans cost substantially more than simple interest loans over the same term."
              ]
            },
            example: {
              heading: "Example: Comparing Both Interest Types",
              scenario: "You invest $15,000 at a 6% annual rate for 20 years.",
              steps: [
                "Simple interest total: $15,000 + ($15,000 x 0.06 x 20) = $15,000 + $18,000 = $33,000.",
                "Compound interest total (annual): $15,000 x (1.06)^20 = approximately $48,107.",
                "The compound interest advantage: $48,107 - $33,000 = $15,107 more earned through compounding.",
                "After 30 years the gap grows further: $42,000 simple vs $86,226 compound — a $44,226 difference.",
                "This illustrates why compound interest is called the eighth wonder of the world by financial educators."
              ]
            },
            tips: [
              "Always choose compound interest accounts for savings and investments. The compounding advantage grows exponentially and can double your returns over decades.",
              "When borrowing, simple interest loans are preferable because total interest costs are lower and more predictable than compound interest loans.",
              "Some auto loans and personal loans use simple interest, which benefits borrowers who make extra payments since the interest does not compound on the remaining balance.",
              "Understand that advertised APR on compound interest products understates the true annual cost or return. Always look at the APY to see the effective rate after compounding."
            ],
            faq: [
              {
                question: "Which is better for savings: simple or compound interest?",
                answer: "Compound interest is always better for savings because you earn interest on your accumulated " \
                        "interest, creating exponential rather than linear growth. Over 30 years at 5%, compound " \
                        "interest produces 2.7 times more total interest than simple interest on the same principal. " \
                        "Virtually all modern savings accounts and CDs use compound interest, making it the default " \
                        "for consumer savings products."
              },
              {
                question: "Do any financial products still use simple interest?",
                answer: "Yes, several common financial products use simple interest. Most auto loans, some personal loans, " \
                        "and Treasury bonds calculate interest on the original principal only. Simple interest is also used " \
                        "for short-term loans, promissory notes, and some student loans during deferment periods. These " \
                        "products are borrower-friendly because the total interest cost is lower and more predictable."
              },
              {
                question: "How much more does compound interest earn over 10 years?",
                answer: "The advantage depends on the rate. At 5% over 10 years on $10,000: simple interest earns $5,000 " \
                        "while compound earns $6,289 — a 26% advantage. At 8%, simple earns $8,000 and compound earns " \
                        "$11,589 — a 45% advantage. At 12%, simple earns $12,000 and compound earns $21,058 — a 75% " \
                        "advantage. Higher rates amplify the compounding effect dramatically."
              },
              {
                question: "Why do credit cards use compound interest?",
                answer: "Credit card companies use compound interest (specifically, daily compounding) because it " \
                        "maximizes the interest revenue they collect from cardholders who carry balances. At a 22% APR " \
                        "compounded daily, the effective annual rate is about 24.6%. This is why financial advisors " \
                        "emphasize paying off credit card balances in full each month to avoid the compounding penalty."
              }
            ],
            related_slugs: [
              "daily-compound-interest-calculator",
              "monthly-compound-interest-calculator",
              "money-doubling-time-calculator"
            ],
            base_calculator_slug: "compound-interest-calculator",
            base_calculator_path: :finance_compound_interest_path
          }
        ]
      }.freeze
    end
  end
end
