module ProgrammaticSeo
  module Content
    module Loan
      DEFINITION = {
        base_key: "loan",
        category: "finance",
        stimulus_controller: "loan-calculator",
        form_partial: "programmatic/forms/loan",
        icon_path: "M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z",
        expansions: [
          {
            slug: "loan-extra-payment-calculator",
            route_name: "programmatic_loan_extra_payment",
            title: "Loan Payment Calculator with Extra Payments | Calc Hammer",
            h1: "Loan Extra Payment Calculator",
            meta_description: "Calculate how extra loan payments reduce your payoff time and total interest. See exactly how much you save by paying more each month.",
            intro: "Making extra payments on your loan is one of the most straightforward ways to save money on " \
                   "interest and become debt-free faster. This calculator shows you exactly how much time and " \
                   "money you save by adding extra principal payments to your regular monthly installment. Whether " \
                   "you can add $50 or $500 per month, the results are often surprising — even small additional " \
                   "payments can shave years off a long-term loan and save thousands in total interest charges.",
            how_it_works: {
              heading: "How Extra Loan Payments Save You Money",
              paragraphs: [
                "When you make an extra payment on a loan, the additional amount goes directly toward reducing " \
                "the outstanding principal balance. Since interest is calculated on the remaining balance, a " \
                "lower principal means less interest accrues each month going forward. This creates a cascading " \
                "effect: each extra payment reduces future interest charges, which means more of your regular " \
                "payment goes to principal, accelerating the payoff even further.",
                "The savings are most dramatic early in the loan when the balance is highest and interest " \
                "charges are at their peak. On a 30-year mortgage, the first five years of extra payments have " \
                "a much larger impact than the same payments made in the final five years. This is because " \
                "the reduced principal has more time to compound the savings across all remaining payments.",
                "This calculator compares your original amortization schedule against a modified schedule that " \
                "includes your planned extra payments. It shows the revised payoff date, the total interest " \
                "saved, and the number of payments eliminated. You can model one-time lump sum payments, " \
                "recurring monthly extras, or a combination of both to find the strategy that fits your budget."
              ]
            },
            example: {
              heading: "Example: Extra Payments on an Auto Loan",
              scenario: "You have a $25,000 auto loan at 6.5% interest for 60 months with a monthly payment of $489.",
              steps: [
                "Enter the loan amount of $25,000, 6.5% rate, and 60-month term.",
                "Without extra payments, you pay $4,341 in total interest over the life of the loan.",
                "Adding $100 per month in extra payments reduces the term to 47 months, saving 13 months.",
                "Total interest drops to $3,305, saving $1,036 in interest charges.",
                "Adding $200 extra per month cuts the term to 39 months and saves $1,760 in interest."
              ]
            },
            tips: [
              "Confirm with your lender that extra payments are applied to principal and not held for the next scheduled payment. Some lenders require you to specify principal-only.",
              "Focus extra payments on your highest-interest loan first if you have multiple debts. This is the debt avalanche method and minimizes total interest paid across all loans.",
              "Even rounding up your payment to the next $50 or $100 increment creates a small but consistent extra payment that adds up significantly over the life of the loan.",
              "If your lender charges a prepayment penalty, calculate whether the interest savings from extra payments exceed the penalty before proceeding with this strategy."
            ],
            faq: [
              {
                question: "How much do extra loan payments actually save?",
                answer: "The savings depend on your interest rate, remaining balance, and how much extra you pay. On " \
                        "a $200,000 mortgage at 6.5% for 30 years, an extra $200 per month saves approximately $89,000 " \
                        "in total interest and pays off the loan 8 years early. On a $20,000 auto loan at 7% for " \
                        "5 years, an extra $100 monthly saves about $900 in interest and eliminates 11 months of payments."
              },
              {
                question: "Is it better to make extra payments or invest the money?",
                answer: "If your loan interest rate is higher than the expected return on investments after taxes, extra " \
                        "payments provide a guaranteed return equal to your interest rate. For high-interest debt above " \
                        "6-7%, paying it down is almost always the better choice. For low-interest debt below 4-5%, " \
                        "investing may produce higher long-term returns, though the guaranteed savings from extra " \
                        "payments carry no risk."
              },
              {
                question: "Do extra payments go toward principal or interest?",
                answer: "Extra payments should go entirely toward reducing the principal balance. Most lenders apply " \
                        "the regular payment to interest first and then principal as scheduled, with any additional " \
                        "amount reducing the principal further. Verify with your lender that extra payments are handled " \
                        "this way. Some require you to explicitly designate the extra amount as a principal payment " \
                        "to prevent it from being applied to future scheduled payments."
              },
              {
                question: "Are there penalties for making extra loan payments?",
                answer: "Most auto loans and personal loans do not have prepayment penalties. Some mortgages, " \
                        "particularly those originated before 2014, may include prepayment penalty clauses that " \
                        "charge a fee for paying off the loan early. Check your loan agreement or ask your servicer. " \
                        "Federal regulations prohibit prepayment penalties on most qualified residential mortgages " \
                        "originated after January 2014."
              }
            ],
            related_slugs: [
              "loan-payoff-date-calculator",
              "loan-interest-calculator",
              "loan-comparison-calculator"
            ],
            base_calculator_slug: "loan-calculator",
            base_calculator_path: :finance_loan_path
          },
          {
            slug: "how-much-can-i-borrow-calculator",
            route_name: "programmatic_how_much_can_i_borrow",
            title: "How Much Can I Borrow Calculator | Calc Hammer",
            h1: "How Much Can I Borrow Calculator",
            meta_description: "Find out the maximum loan amount you can qualify for based on your income, expenses, and desired payment. Get a realistic borrowing limit instantly.",
            intro: "Before you start shopping for a car, home, or any major purchase that requires financing, knowing " \
                   "your maximum borrowing power prevents wasted time and disappointment. This calculator works backward " \
                   "from your income, existing debts, and the monthly payment you can comfortably afford to determine " \
                   "the largest loan amount available to you at current interest rates. Enter your financial details to " \
                   "get a clear borrowing limit that keeps you within safe debt-to-income guidelines.",
            how_it_works: {
              heading: "How Your Maximum Loan Amount Is Calculated",
              paragraphs: [
                "The calculator uses your gross monthly income and existing debt payments to determine how much " \
                "room you have for additional loan payments. Lenders typically require that your total monthly debt " \
                "obligations, including the new loan, not exceed 36-43% of your gross monthly income. This ratio, " \
                "called the debt-to-income ratio (DTI), is the primary constraint on how much you can borrow.",
                "Once the maximum affordable monthly payment is established, the calculator uses the standard " \
                "amortization formula to reverse-engineer the loan amount that produces that payment at a given " \
                "interest rate and term. A longer term or lower rate increases the maximum borrowable amount " \
                "because the same monthly payment supports a larger principal when spread over more months or " \
                "when less of each payment goes to interest.",
                "The calculator shows results for multiple loan terms so you can see the tradeoff between " \
                "borrowing more over a longer period and paying less total interest with a shorter term. It " \
                "also highlights how the interest rate affects your maximum — even a half-point rate difference " \
                "can shift your borrowing limit by thousands of dollars, making rate shopping essential before " \
                "committing to any loan."
              ]
            },
            example: {
              heading: "Example: Determining Your Borrowing Limit",
              scenario: "You earn $65,000 annually with $400 per month in existing debt payments and want a 5-year loan at 7%.",
              steps: [
                "Gross monthly income: $65,000 / 12 = $5,417.",
                "Maximum total debt payments at 36% DTI: $5,417 x 0.36 = $1,950 per month.",
                "Available for new loan: $1,950 - $400 existing debt = $1,550 per month.",
                "Maximum loan at 7% for 60 months: approximately $78,000.",
                "At 5% interest instead, the same payment supports a loan of approximately $82,500."
              ]
            },
            tips: [
              "Pay down credit card balances before applying for a new loan. Reducing existing monthly debt obligations directly increases the amount you can borrow.",
              "Just because you qualify for a certain amount does not mean you should borrow the maximum. Keep your total debt payments at or below 30% of gross income for financial comfort.",
              "Get pre-approved at multiple lenders to find the best rate. Each lender may offer a slightly different maximum based on their underwriting criteria and the rate they quote.",
              "Consider a longer loan term to qualify for a larger amount, but calculate the total interest cost. A 72-month auto loan lets you borrow more but costs significantly more in interest."
            ],
            faq: [
              {
                question: "What determines how much I can borrow?",
                answer: "Your borrowing limit is primarily determined by your income, existing debt obligations, credit " \
                        "score, the interest rate offered, and the loan term. Lenders use your debt-to-income ratio " \
                        "as the key metric, typically capping total monthly debt payments at 36-43% of gross monthly " \
                        "income. A higher credit score usually unlocks better rates, which increases your maximum " \
                        "borrowable amount for the same monthly payment."
              },
              {
                question: "What is a good debt-to-income ratio for borrowing?",
                answer: "A DTI below 36% is generally considered good and gives you access to the most favorable " \
                        "loan terms. Between 36-43%, you can typically still qualify but may face higher rates. " \
                        "Above 43%, most conventional lenders will decline the application. Some government-backed " \
                        "programs allow DTIs up to 50% with compensating factors like a large down payment or " \
                        "substantial savings reserves."
              },
              {
                question: "Does my credit score affect how much I can borrow?",
                answer: "Your credit score affects the interest rate you are offered, which indirectly determines " \
                        "your maximum loan amount. A borrower with a 750 credit score might receive a 6% rate, while " \
                        "someone at 650 might be offered 9%. At the same monthly payment, the 6% borrower can finance " \
                        "a significantly larger amount because less of each payment goes to interest. Improving your " \
                        "credit score before borrowing increases both your rate options and your maximum loan size."
              },
              {
                question: "Should I borrow the maximum amount I qualify for?",
                answer: "Borrowing the maximum is generally not advisable. The maximum represents what lenders believe " \
                        "you can repay based on income ratios, but it does not account for your full financial picture " \
                        "including savings goals, emergency funds, and lifestyle expenses. Borrowing 70-80% of your " \
                        "maximum provides a cushion for unexpected expenses and prevents the financial stress that " \
                        "comes with being stretched to your limit."
              }
            ],
            related_slugs: [
              "loan-interest-calculator",
              "loan-comparison-calculator",
              "loan-extra-payment-calculator"
            ],
            base_calculator_slug: "loan-calculator",
            base_calculator_path: :finance_loan_path
          },
          {
            slug: "loan-interest-calculator",
            route_name: "programmatic_loan_interest",
            title: "Loan Interest Calculator | Calc Hammer",
            h1: "Loan Interest Calculator",
            meta_description: "Calculate the total interest you will pay on any loan. See how rate, term, and payment schedule affect your total borrowing cost.",
            intro: "The interest on a loan is the true cost of borrowing money, and it often adds up to a startling " \
                   "percentage of the original amount borrowed. This calculator shows you exactly how much interest " \
                   "you will pay over the life of any loan based on the principal, rate, and term. Understanding " \
                   "your total interest cost helps you make better decisions about how much to borrow, which rate " \
                   "to accept, and whether a shorter loan term might save you money despite higher monthly payments.",
            how_it_works: {
              heading: "How Loan Interest Is Calculated",
              paragraphs: [
                "Most consumer loans use amortizing interest, meaning each monthly payment covers the interest " \
                "accrued since the last payment plus a portion of the principal. In the early months, a large " \
                "percentage of each payment goes to interest because the outstanding balance is at its highest. " \
                "As the principal decreases with each payment, less interest accrues, and progressively more of " \
                "each payment reduces the balance.",
                "Total interest over the life of a loan is calculated by multiplying the monthly payment by the " \
                "total number of payments and subtracting the original loan amount. The monthly payment itself is " \
                "derived from the amortization formula, which distributes principal and interest evenly across all " \
                "payments. The calculator performs this math instantly for any combination of amount, rate, and term.",
                "The relationship between rate, term, and total interest is not linear. Doubling the loan term does " \
                "not simply double the interest — it more than doubles it because the higher balance persists longer. " \
                "Similarly, a small rate difference compounds over many years. On a $30,000 loan for 5 years, the " \
                "difference between 5% and 7% is about $1,600 in total interest. For a 30-year mortgage at the same " \
                "rates, the difference exceeds $40,000."
              ]
            },
            example: {
              heading: "Example: Total Interest on a Personal Loan",
              scenario: "You take out a $15,000 personal loan at 9% APR for 48 months.",
              steps: [
                "Enter $15,000 as the loan amount, 9% as the interest rate, and 48 months as the term.",
                "Monthly payment: approximately $373.",
                "Total payments over 48 months: $373 x 48 = $17,904.",
                "Total interest paid: $17,904 - $15,000 = $2,904.",
                "The loan costs you an additional 19.4% of the borrowed amount in interest charges."
              ]
            },
            tips: [
              "Compare total interest costs across different loan terms, not just monthly payments. A lower monthly payment over a longer term often costs far more in total interest.",
              "Negotiate the interest rate before signing. Even a 0.5% reduction on a $25,000 five-year loan saves approximately $350 in total interest.",
              "Consider making a larger down payment to reduce the loan amount. Less principal borrowed means less total interest paid, even at the same rate and term.",
              "If you have good credit but are offered a high rate, shop at credit unions and online lenders who often provide more competitive rates than traditional banks."
            ],
            faq: [
              {
                question: "How much interest will I pay on my loan?",
                answer: "Total interest depends on three factors: the amount borrowed, the interest rate, and the " \
                        "loan term. A $20,000 loan at 6% for 5 years costs approximately $3,200 in total interest. " \
                        "The same amount at 10% for 5 years costs about $5,500. Extending to 7 years at 6% increases " \
                        "total interest to approximately $4,500. Use the calculator above with your specific numbers " \
                        "for an exact figure."
              },
              {
                question: "Does paying biweekly reduce total interest?",
                answer: "Yes. Biweekly payments result in 26 half-payments per year, which equals 13 full monthly " \
                        "payments instead of the standard 12. This extra payment goes entirely to principal, reducing " \
                        "the balance faster and lowering total interest. On a 30-year mortgage, biweekly payments " \
                        "can reduce the term by 4-6 years and save tens of thousands in interest."
              },
              {
                question: "What is the difference between APR and interest rate?",
                answer: "The interest rate is the cost of borrowing the principal amount. APR (Annual Percentage Rate) " \
                        "includes the interest rate plus any fees and charges associated with the loan, expressed as " \
                        "an annual percentage. APR provides a more comprehensive view of the total borrowing cost. " \
                        "For loans with origination fees or points, the APR will be higher than the stated interest " \
                        "rate, making it the better number for comparing loan offers."
              },
              {
                question: "How does loan term length affect total interest?",
                answer: "Longer loan terms dramatically increase total interest because the principal balance remains " \
                        "higher for a longer period. A $30,000 loan at 6% for 3 years costs $2,850 in total interest. " \
                        "The same loan stretched to 7 years costs $6,900 — more than double. While longer terms lower " \
                        "the monthly payment, they significantly increase the true cost of the purchase."
              }
            ],
            related_slugs: [
              "loan-extra-payment-calculator",
              "loan-payoff-date-calculator",
              "loan-comparison-calculator"
            ],
            base_calculator_slug: "loan-calculator",
            base_calculator_path: :finance_loan_path
          },
          {
            slug: "loan-payoff-date-calculator",
            route_name: "programmatic_loan_payoff_date",
            title: "Loan Payoff Date Calculator | Calc Hammer",
            h1: "Loan Payoff Date Calculator",
            meta_description: "Find out exactly when your loan will be paid off. Enter your balance, rate, and payment to see your debt-free date and total remaining cost.",
            intro: "Knowing your exact loan payoff date transforms an abstract debt into a concrete countdown with a " \
                   "clear finish line. This calculator takes your current loan balance, interest rate, and monthly " \
                   "payment to determine the precise month and year you will make your final payment. You can also " \
                   "experiment with higher payments to see how increasing your monthly amount moves the payoff date " \
                   "closer, giving you the motivation and planning power to become debt-free on your own timeline.",
            how_it_works: {
              heading: "How the Payoff Date Is Calculated",
              paragraphs: [
                "The calculator uses the amortization formula solved for the number of periods to determine how " \
                "many months remain until the loan balance reaches zero. It divides each payment into interest " \
                "and principal portions, subtracts the principal from the remaining balance, and repeats until " \
                "the balance is eliminated. The result is a specific number of remaining payments, which translates " \
                "to a calendar date based on your next scheduled payment.",
                "If you enter a payment amount higher than your required minimum, the calculator shows the " \
                "accelerated payoff date alongside the original one. The difference can be dramatic. On a " \
                "credit card balance of $8,000 at 22% APR, the minimum payment might not pay off the debt for " \
                "over 20 years, while a fixed payment of $300 per month eliminates it in just 3 years.",
                "The calculator also displays the total remaining cost, including all interest that will accrue " \
                "between now and your payoff date. This figure is often the most motivating output because it " \
                "shows exactly how much money you save in interest by paying off the loan sooner rather than " \
                "making only minimum payments for the full remaining term."
              ]
            },
            example: {
              heading: "Example: Finding Your Payoff Date",
              scenario: "You have a student loan with a $18,500 remaining balance at 5.8% interest, making payments of $280 per month.",
              steps: [
                "Enter $18,500 as the remaining balance, 5.8% as the interest rate, and $280 as the monthly payment.",
                "The calculator determines 79 remaining payments, giving a payoff date approximately 6 years and 7 months from now.",
                "Total remaining interest: approximately $3,620.",
                "Increasing payments to $350 per month reduces the payoff to 61 months and saves $830 in interest.",
                "At $450 per month, payoff drops to 46 months, saving $1,590 compared to the original payment."
              ]
            },
            tips: [
              "Post your calculated payoff date somewhere visible as a motivational reminder. Having a specific date creates accountability and makes the goal feel tangible.",
              "Any windfall money — tax refunds, bonuses, gifts — applied as extra payments moves your payoff date forward and reduces total interest disproportionately.",
              "If you have multiple loans, calculate the payoff date for each one. Use the debt avalanche (highest interest first) or snowball (smallest balance first) method to prioritize.",
              "Set up autopay for more than the minimum to ensure you consistently make progress. Manual payments are easier to skip or reduce during busy months."
            ],
            faq: [
              {
                question: "How do I calculate when my loan will be paid off?",
                answer: "You need three numbers: your current remaining balance, the interest rate, and your monthly " \
                        "payment amount. The amortization formula calculates how many payments are required to reduce " \
                        "the balance to zero. Each payment first covers the monthly interest charge, and the remainder " \
                        "reduces the principal. As the principal shrinks, more of each payment goes to principal, " \
                        "gradually accelerating the payoff."
              },
              {
                question: "Why does my payoff date seem so far away?",
                answer: "If you are making only minimum payments, especially on credit cards, a large portion of " \
                        "each payment covers interest rather than reducing principal. At 20% APR, a $5,000 balance " \
                        "with minimum payments of 2% of the balance would take over 30 years to pay off. Switching " \
                        "to a fixed payment amount that exceeds the interest charge by a meaningful margin dramatically " \
                        "shortens the timeline."
              },
              {
                question: "How much faster will extra payments pay off my loan?",
                answer: "The impact depends on your current rate, balance, and payment size. Generally, increasing " \
                        "your payment by 20% reduces the loan term by roughly 25-30%. On a 60-month auto loan, " \
                        "paying an extra 20% each month can eliminate about 15 months. On a 30-year mortgage, the " \
                        "same proportional increase can cut 6-8 years off the term."
              },
              {
                question: "Does refinancing change my payoff date?",
                answer: "Refinancing resets your loan with new terms, which can either shorten or extend your payoff " \
                        "date depending on the new rate and term. Refinancing to a lower rate with the same term " \
                        "shortens the payoff because more of each payment goes to principal. Refinancing to a " \
                        "longer term extends the payoff date but lowers the monthly payment. Always compare total " \
                        "remaining interest under both scenarios."
              }
            ],
            related_slugs: [
              "loan-extra-payment-calculator",
              "loan-interest-calculator",
              "how-much-can-i-borrow-calculator"
            ],
            base_calculator_slug: "loan-calculator",
            base_calculator_path: :finance_loan_path
          },
          {
            slug: "loan-comparison-calculator",
            route_name: "programmatic_loan_comparison",
            title: "Loan Comparison Calculator | Calc Hammer",
            h1: "Loan Comparison Calculator",
            meta_description: "Compare two or more loan offers side by side. See the difference in monthly payments, total interest, and total cost to find the best deal.",
            intro: "When you receive multiple loan offers, comparing them on monthly payment alone can be misleading " \
                   "because different rates and terms produce wildly different total costs over the life of the loan. " \
                   "This calculator displays two loan scenarios side by side, showing the monthly payment, total " \
                   "interest paid, total cost, and the overall dollar difference between them. Use it to evaluate " \
                   "competing offers from different lenders or to weigh the tradeoffs between a shorter term with " \
                   "higher payments and a longer term with lower payments.",
            how_it_works: {
              heading: "How the Loan Comparison Calculator Works",
              paragraphs: [
                "Enter the details of two loan offers: amount, interest rate, term, and any fees. The calculator " \
                "computes the monthly payment, total interest, and total cost for each scenario using the standard " \
                "amortization formula. It then displays the results side by side with the differences highlighted, " \
                "making it immediately clear which offer saves you money overall.",
                "The comparison accounts for the fact that a lower monthly payment does not always mean a better " \
                "deal. A 72-month auto loan at 6% has a lower monthly payment than a 48-month loan at 5%, but " \
                "the longer loan costs substantially more in total interest. The calculator reveals this hidden " \
                "cost by showing both the monthly and lifetime perspectives simultaneously.",
                "When comparing loans with different fee structures, the calculator incorporates origination " \
                "fees, points, and closing costs into the total cost comparison. A loan with a slightly higher " \
                "rate but no fees may be cheaper overall than a lower-rate loan that charges thousands in upfront " \
                "costs, especially if you plan to pay off the loan early. The true APR comparison includes all " \
                "these costs for an apples-to-apples evaluation."
              ]
            },
            example: {
              heading: "Example: Comparing Two Auto Loan Offers",
              scenario: "You need to borrow $28,000 for a car and have two offers from different lenders.",
              steps: [
                "Offer A: $28,000 at 5.9% for 48 months. Monthly payment: $657. Total interest: $3,536.",
                "Offer B: $28,000 at 4.9% for 60 months. Monthly payment: $528. Total interest: $3,680.",
                "Offer B has a $129 lower monthly payment but costs $144 more in total interest.",
                "If you can afford the higher payment, Offer A saves money overall and frees you from debt a year sooner.",
                "If cash flow is tight, Offer B provides relief now but costs slightly more over the full term."
              ]
            },
            tips: [
              "Always compare the total cost of borrowing, not just the monthly payment. A lower payment spread over more months often costs thousands more in total interest.",
              "Ask each lender for the APR, not just the interest rate. APR includes fees and gives a true cost comparison even when loan structures differ.",
              "If two offers have similar total costs, choose the one with the shorter term. Being debt-free sooner provides financial flexibility and reduces overall risk.",
              "Consider whether one lender offers benefits the other does not, such as rate discounts for autopay, no prepayment penalties, or hardship deferment options."
            ],
            faq: [
              {
                question: "How do I compare loan offers with different terms?",
                answer: "Calculate the total cost for each offer: multiply the monthly payment by the number of months " \
                        "and add any upfront fees. The loan with the lower total cost is the better financial deal, " \
                        "regardless of the monthly payment amount. Also compare the total interest paid separately " \
                        "to understand how much of your money goes to the lender versus your principal."
              },
              {
                question: "Is a lower interest rate always the better loan?",
                answer: "Not necessarily. A lower rate with high origination fees or a longer term can cost more overall " \
                        "than a slightly higher rate with no fees and a shorter term. For example, a 4.5% loan with " \
                        "$2,000 in fees over 60 months may cost more than a 5.0% loan with no fees over 48 months. " \
                        "Always calculate total cost including all fees to make a true comparison."
              },
              {
                question: "Should I choose the loan with the lowest monthly payment?",
                answer: "Only if cash flow is your primary concern. The lowest monthly payment usually comes from the " \
                        "longest term, which maximizes total interest. If you can comfortably afford a higher monthly " \
                        "payment, choosing a shorter-term loan saves significant money. The ideal balance is a payment " \
                        "you can sustain without financial stress while minimizing total borrowing cost."
              },
              {
                question: "How do I account for origination fees in a comparison?",
                answer: "Add origination fees to the total interest paid for each loan to get the true total borrowing " \
                        "cost. Alternatively, compare the APR of each loan, which already incorporates fees into an " \
                        "annual percentage. A loan charging 1% origination on $30,000 adds $300 to your costs. If " \
                        "the other loan has no fee, it needs to save you at least $300 in interest to break even."
              }
            ],
            related_slugs: [
              "loan-interest-calculator",
              "how-much-can-i-borrow-calculator",
              "loan-payoff-date-calculator"
            ],
            base_calculator_slug: "loan-calculator",
            base_calculator_path: :finance_loan_path
          }
        ]
      }.freeze
    end
  end
end
