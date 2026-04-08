module ProgrammaticSeo
  module Content
    module Discount
      DEFINITION = {
        base_key: "discount",
        category: "everyday",
        stimulus_controller: "discount-calculator",
        form_partial: "programmatic/forms/discount",
        icon_path: "M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A2 2 0 013 12V7a4 4 0 014-4z",
        expansions: [
          {
            slug: "double-discount-calculator",
            route_name: "programmatic_double_discount",
            title: "Double Discount Calculator | CalcWise",
            h1: "Double Discount Calculator",
            meta_description: "Calculate the final price after two successive discounts. See why a 20% + 10% discount is not the same as 30% off and find the true savings.",
            intro: "Double discounts occur when two percentage reductions are applied one after the other, such as " \
                   "a store-wide sale combined with a coupon code, or an employee discount stacked on top of a " \
                   "clearance markdown. Many shoppers assume that 20% off plus 10% off equals 30% off, but this " \
                   "is incorrect because the second discount applies to the already-reduced price. This calculator " \
                   "shows you the exact final price, the true combined discount percentage, and how much you actually " \
                   "save when two discounts are stacked.",
            how_it_works: {
              heading: "How Double Discounts Work",
              paragraphs: [
                "A double discount applies two percentage reductions sequentially rather than additively. The " \
                "first discount is calculated on the original price, producing a reduced price. The second " \
                "discount is then calculated on that reduced price, not the original. Mathematically, the " \
                "combined effect is: final price = original price x (1 - first discount) x (1 - second discount). " \
                "This always results in a smaller total discount than simply adding the two percentages together.",
                "For example, an item priced at $100 with a 20% discount followed by a 10% discount first drops " \
                "to $80 after the first reduction, then to $72 after the second. The total savings is $28, which " \
                "is a 28% effective discount — not 30%. The order of the discounts does not matter mathematically; " \
                "10% then 20% produces the same $72 final price as 20% then 10%.",
                "This calculation matters most for expensive purchases where even small percentage differences " \
                "translate to meaningful dollar amounts. On a $1,500 appliance with a 25% sale plus a 15% coupon, " \
                "the true combined discount is 36.25% ($543.75 off) rather than the 40% ($600 off) that adding " \
                "the percentages would suggest. Understanding this prevents overestimating savings and helps you " \
                "budget accurately."
              ]
            },
            example: {
              heading: "Example: Store Sale Plus Coupon",
              scenario: "A jacket originally priced at $180 is on a 30% off sale, and you have a 15% off coupon that stacks.",
              steps: [
                "First discount (30% off): $180 x 0.70 = $126 after the sale markdown.",
                "Second discount (15% coupon): $126 x 0.85 = $107.10 after applying the coupon.",
                "Total savings: $180 - $107.10 = $72.90 off the original price.",
                "True combined discount: $72.90 / $180 = 40.5%, not the 45% from adding 30% + 15%.",
                "You saved $8.10 less than a single 45% discount would have provided."
              ]
            },
            tips: [
              "The order of double discounts does not affect the final price. A 20% then 10% discount produces the same result as 10% then 20% because multiplication is commutative.",
              "To quickly estimate a double discount, multiply the two keep-percentages. For 30% off plus 20% off: 0.70 x 0.80 = 0.56, meaning you pay 56% of the original (44% off total).",
              "Some retailers advertise stacked discounts to make deals seem larger than they are. Always calculate the true combined percentage before assuming you are getting a bargain.",
              "If given the choice between a single larger discount and two smaller stacked discounts that add to the same number, the single discount always saves more money."
            ],
            faq: [
              {
                question: "Why is 20% off plus 10% off not the same as 30% off?",
                answer: "Because the second discount is applied to the already-reduced price, not the original. After " \
                        "20% off a $100 item, the price is $80. Then 10% off $80 is $8, bringing it to $72. A " \
                        "straight 30% off $100 would be $70. The difference exists because the second discount has " \
                        "a smaller base to work with, so it removes fewer dollars than it would from the original price."
              },
              {
                question: "Does the order of discounts matter?",
                answer: "No, the final price is the same regardless of which discount is applied first. This is because " \
                        "multiplication is commutative: price x 0.80 x 0.90 equals price x 0.90 x 0.80. The total " \
                        "savings amount and effective discount percentage are identical either way. However, some " \
                        "stores may have policies about which discount applies first, which does not change the math " \
                        "but may affect how the receipt is displayed."
              },
              {
                question: "How do I calculate the true combined discount percentage?",
                answer: "Multiply the complement of each discount (1 minus the discount rate). For 25% and 15%: " \
                        "(1 - 0.25) x (1 - 0.15) = 0.75 x 0.85 = 0.6375. Subtract from 1 to get the combined " \
                        "discount: 1 - 0.6375 = 0.3625, or 36.25%. This is always less than the sum of the " \
                        "individual discounts (40% in this case)."
              },
              {
                question: "Can I have triple or more stacked discounts?",
                answer: "Yes, the same principle extends to any number of stacked discounts. Each successive discount " \
                        "is applied to the progressively reduced price. Three discounts of 10% each produce an " \
                        "effective discount of 27.1% (not 30%), because 0.90 x 0.90 x 0.90 = 0.729, meaning you " \
                        "pay 72.9% of the original. The gap between the sum and the true discount grows with each " \
                        "additional layer."
              }
            ],
            related_slugs: [
              "percent-off-price-calculator",
              "original-price-before-discount-calculator",
              "bogo-calculator"
            ],
            base_calculator_slug: "discount-calculator",
            base_calculator_path: :everyday_discount_path
          },
          {
            slug: "bogo-calculator",
            route_name: "programmatic_bogo",
            title: "BOGO Calculator - Buy One Get One Free | CalcWise",
            h1: "Buy One Get One (BOGO) Calculator",
            meta_description: "Calculate the real per-unit cost of buy-one-get-one deals. Compare BOGO free, BOGO 50% off, and other promotions to find the true savings.",
            intro: "Buy-one-get-one promotions are among the most popular retail deals, but the actual per-unit savings " \
                   "vary significantly depending on the specific offer. BOGO free is effectively 50% off when you buy " \
                   "two items, while BOGO 50% off is only 25% off per item. This calculator breaks down any BOGO " \
                   "promotion into a clear per-unit price so you can compare it against non-promotional pricing and " \
                   "decide whether the deal is genuinely worth buying extra.",
            how_it_works: {
              heading: "How the BOGO Calculator Works",
              paragraphs: [
                "The calculator takes the item price and the BOGO deal type (free, 50% off, or a custom percentage " \
                "off the second item) to compute the total cost for two items. It then divides by two to show " \
                "your effective per-unit price. For BOGO free at $10 per item, you pay $10 for two, making each " \
                "unit effectively $5. For BOGO 50% off, you pay $10 + $5 = $15 for two, making each unit $7.50.",
                "The key insight is translating BOGO language into a standard per-unit discount. BOGO free equals " \
                "a 50% per-unit discount when you buy exactly two. BOGO 50% off equals a 25% per-unit discount. " \
                "BOGO 30% off equals a 15% per-unit discount. These translations make it easy to compare BOGO " \
                "deals against straightforward percentage-off sales on the same product.",
                "The calculator also helps you evaluate whether buying the extra item makes financial sense. A " \
                "BOGO deal only saves money if you would have purchased the second item anyway or if the per-unit " \
                "price is low enough to justify the extra purchase. Buying something you do not need at 50% off " \
                "is not saving money — it is spending money you would not have spent at all."
              ]
            },
            example: {
              heading: "Example: Comparing BOGO Deals at Different Stores",
              scenario: "A pair of shoes costs $89.99. Store A offers BOGO 50% off. Store B has a flat 30% off sale.",
              steps: [
                "Store A (BOGO 50% off): You buy two pairs at $89.99 + $45.00 = $134.99. Per pair: $67.50 (25% off each).",
                "Store B (30% off): One pair costs $89.99 x 0.70 = $63.00. Two pairs cost $126.00 (per pair: $63.00).",
                "If you need two pairs, Store B saves $8.99 more than the BOGO deal.",
                "If you only need one pair, Store B is the clear winner at $63.00 versus $89.99 at Store A.",
                "The BOGO deal only wins if Store A's second item is free, making each pair $45.00."
              ]
            },
            tips: [
              "Always calculate the per-unit price of a BOGO deal and compare it to the regular per-unit price. Not every BOGO promotion is actually the best available deal.",
              "BOGO free is equivalent to 50% off each item, but only when you buy in pairs. If you need an odd number, the last item is full price, reducing the overall savings.",
              "For perishable items, only take BOGO deals if you can use both items before they expire. Throwing away the second item means you paid full price for the one you kept.",
              "Stack coupons with BOGO deals when store policy allows. A manufacturer coupon applied before the BOGO reduces the base price, amplifying your total savings."
            ],
            faq: [
              {
                question: "Is BOGO free really 50% off?",
                answer: "Yes, when you buy exactly two items. You pay full price for one and get the second at no " \
                        "cost, so your total spend is the price of one item for two items. That is a 50% per-unit " \
                        "discount. However, if you only need one item, you are paying full price and getting an " \
                        "unnecessary item for free, which is not actually saving you money."
              },
              {
                question: "What is better: BOGO 50% off or 30% off everything?",
                answer: "If you are buying exactly two items, BOGO 50% off gives you 25% off per item, while 30% " \
                        "off gives you 30% off per item. The 30% sale is better in this case. If buying only one " \
                        "item, 30% off is dramatically better since BOGO gives you no discount on a single purchase. " \
                        "BOGO 50% off only beats a flat discount when the flat discount is less than 25%."
              },
              {
                question: "Does BOGO apply to the cheaper or more expensive item?",
                answer: "In most retail promotions, the free or discounted item is the one with the lower price. " \
                        "If you buy a $50 item and a $40 item under BOGO free, the $40 item is free, and you pay " \
                        "$50 total. To maximize savings, pair items of equal or similar price so the free item " \
                        "has the highest possible value."
              },
              {
                question: "How do I calculate per-unit cost for buy-two-get-one-free?",
                answer: "Multiply the item price by two (the number you pay for), then divide by three (the total " \
                        "number you receive). For a $15 item with buy-two-get-one-free, you pay $30 for three items, " \
                        "making each one effectively $10. This is a 33.3% per-unit discount. The same logic extends " \
                        "to any buy-X-get-Y-free structure."
              }
            ],
            related_slugs: [
              "double-discount-calculator",
              "percent-off-price-calculator",
              "original-price-before-discount-calculator"
            ],
            base_calculator_slug: "discount-calculator",
            base_calculator_path: :everyday_discount_path
          },
          {
            slug: "percent-off-price-calculator",
            route_name: "programmatic_percent_off_price",
            title: "Percent Off Calculator - Find the Sale Price | CalcWise",
            h1: "Percent Off Price Calculator",
            meta_description: "Calculate the sale price after any percentage discount. Enter the original price and percent off to instantly see how much you save and the final cost.",
            intro: "Percentage-off sales are everywhere — from 15% off a new sweater to 40% off electronics during " \
                   "holiday events. This calculator instantly converts any percent-off deal into the actual dollar " \
                   "amount you save and the final price you pay. No more mental math at the store or guessing whether " \
                   "a deal is worth it. Enter the original price and the discount percentage to see your savings in " \
                   "both dollars and cents, along with the final price including optional sales tax.",
            how_it_works: {
              heading: "How the Percent Off Calculator Works",
              paragraphs: [
                "The formula is straightforward: discount amount = original price x (percentage / 100). Subtract " \
                "the discount from the original price to get the sale price. For a $75 item at 25% off, the " \
                "discount is $75 x 0.25 = $18.75, and the sale price is $75 - $18.75 = $56.25. The calculator " \
                "handles this conversion instantly for any price and any percentage.",
                "When sales tax applies, the calculator adds it to the discounted price rather than the original. " \
                "This matters because you pay tax on the amount you actually spend, not the pre-discount price. " \
                "A $100 item at 20% off with 8% sales tax costs $80 + $6.40 = $86.40, not $100 + $8.00 - $20 = " \
                "$88.00. The tax savings from the lower price add slightly to your overall discount.",
                "The calculator also shows your savings as both a dollar amount and a percentage of the original " \
                "price. This is helpful when stores express discounts in dollar terms (save $15!) rather than " \
                "percentages, since $15 off a $50 item is a much better deal (30% off) than $15 off a $200 item " \
                "(7.5% off). Seeing both values helps you evaluate promotions critically."
              ]
            },
            example: {
              heading: "Example: Holiday Sale Calculation",
              scenario: "A laptop originally priced at $899 is on sale for 35% off during a holiday promotion.",
              steps: [
                "Enter $899 as the original price and 35 as the percent off.",
                "Discount amount: $899 x 0.35 = $314.65.",
                "Sale price: $899 - $314.65 = $584.35.",
                "With 7% sales tax: $584.35 x 1.07 = $625.25 total out of pocket.",
                "Compare this to the full price with tax ($961.93) to see total savings of $336.68."
              ]
            },
            tips: [
              "For quick mental math, calculate 10% of the price first (move the decimal point left), then multiply or adjust. For 25% off, calculate 10% and then add half of 10% plus 10%.",
              "When comparing two items with different discounts, calculate the actual sale price of each rather than comparing percentages. A 40% discount on a more expensive item may still cost more.",
              "Check if the percent-off applies to the current selling price or the original MSRP. Some retailers inflate the original price to make the discount percentage appear larger than the true savings.",
              "Combine percent-off sales with cashback credit cards for additional savings. A 30% store discount plus 5% cashback effectively gives you a 33.5% total discount."
            ],
            faq: [
              {
                question: "How do I calculate the price after a percentage discount?",
                answer: "Multiply the original price by the discount percentage expressed as a decimal, then subtract " \
                        "from the original. Alternatively, multiply the price by (1 minus the discount rate). For " \
                        "20% off $80: $80 x (1 - 0.20) = $80 x 0.80 = $64. Both methods produce the same result. " \
                        "The second method is quicker for mental math because you calculate the price directly."
              },
              {
                question: "Is 50% off a good deal?",
                answer: "A 50% discount is significant, but whether it is a good deal depends on the starting price. " \
                        "Some retailers mark up prices before applying discounts, making 50% off merely the true " \
                        "market value. Check the sale price against competitors and price history tools to verify " \
                        "you are genuinely getting half off the fair market price, not half off an inflated number."
              },
              {
                question: "How do I figure out the original price from the sale price and discount?",
                answer: "Divide the sale price by (1 minus the discount rate). If an item is $60 after a 25% discount: " \
                        "$60 / (1 - 0.25) = $60 / 0.75 = $80 original price. This reverse calculation is useful for " \
                        "verifying that advertised original prices are accurate and for comparing sale prices across " \
                        "stores offering different discount percentages."
              },
              {
                question: "Does sales tax apply before or after the discount?",
                answer: "Sales tax is calculated on the discounted price, not the original. You pay tax on the amount " \
                        "you actually spend. This means discounts reduce both the pre-tax price and the tax amount. " \
                        "A $100 item at 30% off with 8% tax costs $70 + $5.60 = $75.60, saving you $32.40 compared " \
                        "to the full price with tax of $108."
              }
            ],
            related_slugs: [
              "double-discount-calculator",
              "original-price-before-discount-calculator",
              "bogo-calculator"
            ],
            base_calculator_slug: "discount-calculator",
            base_calculator_path: :everyday_discount_path
          },
          {
            slug: "original-price-before-discount-calculator",
            route_name: "programmatic_original_price_before_discount",
            title: "Original Price Before Discount Calculator | CalcWise",
            h1: "Original Price Before Discount Calculator",
            meta_description: "Find the original price of an item from the sale price and discount percentage. Reverse-calculate what an item cost before the markdown was applied.",
            intro: "Sometimes you see a sale price and a discount percentage but the original price is not clearly " \
                   "displayed. Other times, you want to verify that a retailer's claimed original price is legitimate " \
                   "before assuming you are getting a good deal. This calculator works backward from the discounted " \
                   "price and the percentage off to reveal the original price before any markdown was applied. It is " \
                   "an essential tool for smart shoppers who want to confirm that advertised savings are genuine.",
            how_it_works: {
              heading: "How to Calculate the Original Price",
              paragraphs: [
                "The reverse discount formula divides the sale price by (1 minus the discount rate). If you paid " \
                "$63 for an item that was 30% off, the original price was $63 / (1 - 0.30) = $63 / 0.70 = $90. " \
                "This works because the sale price represents the remaining percentage of the original. At 30% " \
                "off, you paid 70% of the original, so dividing by 0.70 recovers the full 100%.",
                "This calculation is particularly useful for verifying deals. Some retailers engage in a practice " \
                "where they inflate the original price to make the discount appear larger. If you see a shirt " \
                "advertised as 60% off at $28, the implied original price is $70. If that shirt has never " \
                "actually been sold for $70, the 60% claim is misleading. Calculating the original price lets " \
                "you cross-reference it against typical market prices.",
                "The calculator handles any discount percentage and can also work with dollar-off discounts. " \
                "If you saved $45 and that represents a 25% discount, the original price was $45 / 0.25 = $180. " \
                "Both input methods — percentage-off with sale price, or dollar savings with discount percentage — " \
                "arrive at the same original price and help you evaluate whether the deal is truly worthwhile."
              ]
            },
            example: {
              heading: "Example: Verifying a Sale Price",
              scenario: "A pair of headphones is marked as 40% off with a sale price of $149.99.",
              steps: [
                "Enter $149.99 as the sale price and 40% as the discount.",
                "Original price = $149.99 / (1 - 0.40) = $149.99 / 0.60 = $249.98.",
                "The retailer claims the original price was $249.99 — this checks out as accurate.",
                "Dollar savings: $249.98 - $149.99 = $99.99 off.",
                "Cross-reference the $249.99 original price with other retailers to confirm it was the actual selling price."
              ]
            },
            tips: [
              "Use price tracking tools and browser extensions to verify that the original price claimed by the retailer was the actual recent selling price, not an inflated reference point.",
              "When shopping outlet stores, calculate the original price from the discount and compare it to the same item at full-price retailers. Outlet-specific items may have inflated originals.",
              "Keep receipts with the calculated original price for price-adjustment claims if the item goes on a deeper sale within the return window at certain stores.",
              "For international shopping where prices are in foreign currencies, calculate the original price first in the local currency, then convert to your currency for an accurate comparison."
            ],
            faq: [
              {
                question: "How do I find the original price from a sale price?",
                answer: "Divide the sale price by (1 minus the discount expressed as a decimal). For an item at $56 " \
                        "after a 20% discount: $56 / (1 - 0.20) = $56 / 0.80 = $70 original price. This formula " \
                        "works because the sale price represents the percentage of the original that you actually " \
                        "paid. Dividing by that percentage reverses the calculation to reveal the full original amount."
              },
              {
                question: "How can I tell if the original price is inflated?",
                answer: "Compare the calculated original price against the same product at competing retailers, check " \
                        "price history using tools like CamelCamelCamel for Amazon or Google Shopping for general " \
                        "retail, and read reviews that may mention typical pricing. If no other retailer has ever " \
                        "sold the item at the claimed original price, the discount percentage is likely exaggerated."
              },
              {
                question: "Is the original price the same as MSRP?",
                answer: "Not always. MSRP (Manufacturer's Suggested Retail Price) is the price recommended by the " \
                        "maker, but retailers can sell above or below it. Many retailers set their own original " \
                        "price higher than MSRP to create the appearance of a larger discount. Others regularly " \
                        "sell below MSRP, making the MSRP itself a misleading reference point for calculating " \
                        "true savings."
              },
              {
                question: "What if two discounts were applied to reach the sale price?",
                answer: "If two sequential discounts were applied, you need to reverse each one individually. First " \
                        "divide the final price by (1 minus the second discount), then divide that result by (1 minus " \
                        "the first discount). For $54 after 10% then 20% off: $54 / 0.90 = $60 (after first discount), " \
                        "then $60 / 0.80 = $75 original price. The order of reversal is the opposite of the order " \
                        "the discounts were applied."
              }
            ],
            related_slugs: [
              "percent-off-price-calculator",
              "double-discount-calculator",
              "bogo-calculator"
            ],
            base_calculator_slug: "discount-calculator",
            base_calculator_path: :everyday_discount_path
          }
        ]
      }.freeze
    end
  end
end
