module ProgrammaticSeo
  module Content
    module Tip
      DEFINITION = {
        base_key: "tip",
        category: "everyday",
        stimulus_controller: "tip-calculator",
        form_partial: "programmatic/forms/tip",
        icon_path: "M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z",
        expansions: [
          {
            slug: "restaurant-tip-percentage-calculator",
            route_name: "programmatic_restaurant_tip_percentage",
            title: "Restaurant Tip Percentage Calculator | Calc Hammer",
            h1: "Restaurant Tip Percentage Calculator",
            meta_description: "Calculate the right tip percentage at restaurants. Get suggested amounts for counter service, casual dining, and fine dining based on your bill total.",
            intro: "Figuring out how much to tip at a restaurant should never feel stressful. This calculator removes the guesswork " \
                   "by showing you exactly what 15%, 18%, 20%, and 25% tips look like on your specific bill. Whether you are " \
                   "grabbing a quick lunch at a casual spot or enjoying a multi-course dinner at a high-end establishment, " \
                   "you will see a clear breakdown of the tip amount, your total per person, and how to round for convenience. " \
                   "Enter your bill total and party size to get started.",
            how_it_works: {
              heading: "How the Restaurant Tip Calculator Works",
              paragraphs: [
                "Start by entering your pre-tax bill total. The calculator multiplies that amount by each standard " \
                "tip percentage to show side-by-side comparisons. Using the pre-tax total is the accepted practice in " \
                "the United States because taxes vary widely by state and should not inflate the gratuity your server receives.",
                "Next, specify the number of people in your party. The calculator divides both the tip and the final " \
                "total evenly so every guest knows their share. This is particularly useful for large groups where splitting " \
                "the check can otherwise lead to confusion or underpayment of the tip.",
                "Finally, review the suggested totals and choose the percentage that matches the level of service you " \
                "received. For standard service at a sit-down restaurant, 18% to 20% is customary in the US. Exceptional " \
                "service or fine dining often warrants 20% to 25%, while counter-service spots typically merit 15% or less."
              ]
            },
            example: {
              heading: "Example: Dinner for Four",
              scenario: "Your party of four has a pre-tax dinner bill of $120 at a mid-range restaurant.",
              steps: [
                "Enter a bill total of $120 and a party size of 4.",
                "At 20%, the tip is $24, making the grand total $144.",
                "Each person owes $36 ($30 for food plus $6 tip).",
                "If service was outstanding, bump to 25% for a $30 tip and $37.50 per person."
              ]
            },
            tips: [
              "Always tip on the pre-tax subtotal rather than the after-tax total to follow standard US dining etiquette and avoid over-calculating your gratuity.",
              "For large parties of six or more, check if an automatic gratuity of 18% to 20% has already been added to the bill before calculating an additional tip.",
              "When dining at a buffet-style restaurant where servers mainly handle drinks and table clearing, a tip of 10% to 15% is generally considered appropriate.",
              "In countries outside the US, tipping norms differ significantly. In Japan tipping is considered rude, while in many European nations a small rounding-up is sufficient."
            ],
            faq: [
              {
                question: "Should I tip on the pre-tax or post-tax amount?",
                answer: "The widely accepted practice in the United States is to tip on the pre-tax subtotal. Since sales tax " \
                        "rates vary from state to state and are not part of the service you received, excluding them gives a " \
                        "fairer baseline. Some diners choose to tip on the post-tax total for simplicity, and servers certainly " \
                        "appreciate the extra, but etiquette guides consistently recommend the pre-tax figure."
              },
              {
                question: "What is the standard restaurant tip percentage in the US?",
                answer: "For sit-down restaurants with full table service, 15% to 20% has been the long-standing norm. In " \
                        "recent years the baseline has shifted closer to 20%, with many diners reserving 15% for merely adequate " \
                        "service. Fine dining establishments often see tips of 20% to 25%. Counter-service and fast-casual spots " \
                        "where you order at a register typically receive 0% to 15%."
              },
              {
                question: "How do I split the tip among a large group?",
                answer: "Divide the total tip evenly by the number of diners for the simplest approach. If individual orders " \
                        "varied dramatically in cost, you can instead have each person calculate the tip on their own items. " \
                        "Many groups find it easiest to agree on a flat percentage, add it to the total bill, and then split " \
                        "the combined amount equally using a payment app."
              },
              {
                question: "Should I still tip if the service was poor?",
                answer: "It is common practice to leave at least 10% even for subpar service, since servers in the US earn " \
                        "a lower base wage and rely on tips for the bulk of their income. If the issue was with the kitchen " \
                        "rather than the server, the full standard tip is appropriate. For genuinely negligent service, speaking " \
                        "with a manager is more constructive than leaving no tip."
              },
              {
                question: "Do I need to tip on takeout orders?",
                answer: "Tipping on takeout is optional but increasingly appreciated, especially since the pandemic. A tip " \
                        "of 10% to 15% acknowledges the staff who packaged your order, included condiments, and ensured " \
                        "accuracy. For large or complex takeout orders that require significant preparation and packing effort, " \
                        "a 15% to 20% tip is a generous way to show gratitude."
              }
            ],
            related_slugs: [
              "delivery-tip-percentage-calculator",
              "buffet-tip-calculator",
              "tipping-etiquette-calculator"
            ],
            base_calculator_slug: "tip-calculator",
            base_calculator_path: :everyday_tip_path
          },
          {
            slug: "delivery-tip-percentage-calculator",
            route_name: "programmatic_delivery_tip_percentage",
            title: "Delivery Tip Calculator for Food Drivers | Calc Hammer",
            h1: "Delivery Tip Percentage Calculator",
            meta_description: "Calculate fair tips for food delivery drivers. Accounts for order size, distance, weather conditions, and service quality to suggest the right amount.",
            intro: "Tipping delivery drivers fairly is important because they use their own vehicles, pay for gas, and " \
                   "often navigate difficult traffic or weather to bring your meal to your door. This calculator helps " \
                   "you determine a suitable tip based on your order total, taking into account factors like distance " \
                   "and conditions. Whether you are ordering through a major delivery app or directly from a local " \
                   "restaurant, use this tool to make sure the person behind the wheel is properly compensated for their effort.",
            how_it_works: {
              heading: "How the Delivery Tip Calculator Works",
              paragraphs: [
                "Enter your order subtotal before any delivery fees or service charges. The calculator applies standard " \
                "delivery tip percentages of 15%, 18%, and 20% so you can compare amounts at a glance. Delivery fees " \
                "paid to the platform rarely go to the driver, which is why the tip matters so much for their earnings.",
                "Consider the circumstances of your delivery. Longer distances, apartment buildings with difficult access, " \
                "heavy rain or snow, and late-night orders all add complexity for the driver. The calculator lets you " \
                "factor in these conditions by adjusting the suggested percentage upward when warranted.",
                "Review the final suggested amounts and pick the one that feels right. A common minimum in the US is " \
                "$3 to $5 regardless of order size, since very small orders still require the driver to make a full " \
                "trip. For orders over $50, sticking with a percentage-based approach usually produces a fair result."
              ]
            },
            example: {
              heading: "Example: Rainy Evening Pizza Delivery",
              scenario: "You order $35 worth of pizza on a rainy evening, delivered from a restaurant 4 miles away.",
              steps: [
                "Enter the order subtotal of $35.",
                "At 20%, the suggested tip is $7.",
                "Given the rain and moderate distance, consider bumping to 25% for an $8.75 tip.",
                "The driver receives a meaningful amount that reflects the extra effort involved."
              ]
            },
            tips: [
              "Tip at least $3 to $5 on small orders since the driver still has to make the full trip regardless of how little you ordered, covering gas and vehicle wear.",
              "Delivery fees charged by apps typically go to the platform, not the driver. Your tip is often the primary way drivers earn income beyond a minimal base payment.",
              "During severe weather such as heavy rain, snow, or extreme heat, consider adding an extra $2 to $5 on top of your usual tip to acknowledge the harder conditions.",
              "If the driver has to climb multiple flights of stairs, navigate a gated community, or wait for building access, a higher tip respects the additional time spent."
            ],
            faq: [
              {
                question: "How much should I tip a food delivery driver?",
                answer: "A tip of 15% to 20% of the order subtotal is standard for food delivery in the United States. For " \
                        "smaller orders under $20, a flat $3 to $5 minimum is recommended because percentage-based tips on " \
                        "low totals may not adequately compensate the driver for their time, fuel, and vehicle costs. Larger " \
                        "orders of $50 or more can follow the percentage approach comfortably."
              },
              {
                question: "Does the delivery fee go to the driver?",
                answer: "In most cases, the delivery fee charged by apps like DoorDash, Uber Eats, or Grubhub goes primarily " \
                        "to the platform, not the driver. Drivers typically receive a small base pay per delivery plus any tips " \
                        "you add. This means your tip is the main way to directly compensate the person who actually brings " \
                        "your food, making it an essential part of the transaction."
              },
              {
                question: "Should I tip more in bad weather?",
                answer: "Yes, tipping more during inclement weather is widely considered good practice. Drivers face increased " \
                        "risks on slippery roads, reduced visibility, and general discomfort during rain, snow, or extreme " \
                        "temperatures. An additional $2 to $5 on top of your usual tip acknowledges those hazards and can " \
                        "make a meaningful difference in the driver's decision to stay on the road."
              },
              {
                question: "Should I tip on the subtotal or the total with fees?",
                answer: "Tip on the food subtotal before delivery fees and service charges are added. Those fees compensate " \
                        "the platform for its technology and logistics infrastructure, not the driver. By tipping on the " \
                        "subtotal, you ensure the gratuity reflects the value of the food you ordered and the service " \
                        "the driver personally provided in getting it to you."
              },
              {
                question: "Is it better to tip in the app or in cash?",
                answer: "Both methods are acceptable, but cash tips have the advantage of going directly to the driver " \
                        "without any platform processing. Some drivers prefer cash because they receive it immediately. " \
                        "However, tipping in the app before delivery can motivate drivers to accept your order more quickly, " \
                        "since they can see the potential earnings upfront before deciding to pick it up."
              }
            ],
            related_slugs: [
              "restaurant-tip-percentage-calculator",
              "taxi-tip-calculator",
              "tipping-etiquette-calculator"
            ],
            base_calculator_slug: "tip-calculator",
            base_calculator_path: :everyday_tip_path
          },
          {
            slug: "hotel-tip-calculator",
            route_name: "programmatic_hotel_tip",
            title: "Hotel Tip Calculator for Staff & Services | Calc Hammer",
            h1: "Hotel Tip Calculator",
            meta_description: "Calculate appropriate tips for hotel housekeeping, bellhops, concierge, valet, and room service. Get per-night and per-service tipping guidelines.",
            intro: "Hotels involve interactions with many different staff members, each providing a distinct service that " \
                   "deserves recognition. From the housekeeper who refreshes your room daily to the bellhop who carries " \
                   "your luggage and the concierge who secures hard-to-get reservations, knowing the right amount to tip " \
                   "each person can be confusing. This calculator provides clear per-service and per-night tipping guidelines " \
                   "so you can show your appreciation without second-guessing yourself.",
            how_it_works: {
              heading: "How the Hotel Tip Calculator Works",
              paragraphs: [
                "Select the hotel services you used during your stay. The calculator covers housekeeping, bellhop or " \
                "porter service, concierge assistance, valet parking, room service delivery, and doorman hailing. Each " \
                "service has its own recommended tipping range based on widely accepted US hospitality guidelines.",
                "Enter details like the number of nights you stayed and how many bags the bellhop carried. The calculator " \
                "uses these inputs to produce specific dollar amounts rather than vague ranges. For housekeeping, the " \
                "standard is $2 to $5 per night, with the amount scaling up for luxury properties or suites.",
                "Review the itemized breakdown showing each service and its suggested tip. You will also see a combined " \
                "total for your entire stay, which makes budgeting simple. Remember that different housekeepers may " \
                "clean your room on different days, so leaving the tip daily ensures each person receives their share."
              ]
            },
            example: {
              heading: "Example: Three-Night Business Trip",
              scenario: "You stay three nights at a full-service hotel, use the bellhop on arrival and departure, and request concierge help once.",
              steps: [
                "Housekeeping at $5 per night for 3 nights equals $15 total.",
                "Bellhop carries 2 bags on arrival ($2 per bag) and departure ($2 per bag) for $8.",
                "Concierge arranged a dinner reservation at a popular restaurant: $10 to $20.",
                "Your estimated total hotel tipping budget is $33 to $43."
              ]
            },
            tips: [
              "Leave housekeeping tips daily rather than as a lump sum at checkout, because different staff members may clean your room on different days of your stay.",
              "Place housekeeping tips on the pillow or nightstand with a note labeled \"for housekeeping\" so the staff member knows the money is intended for them specifically.",
              "Tip the bellhop $2 to $5 per bag depending on the hotel tier. For heavy or oversized luggage, lean toward the higher end to reflect the extra physical effort required.",
              "If the concierge goes above and beyond, such as securing last-minute tickets or hard-to-get reservations, a tip of $10 to $50 is appropriate for exceptional assistance."
            ],
            faq: [
              {
                question: "How much should I tip hotel housekeeping per night?",
                answer: "The American Hotel & Lodging Association suggests $1 to $5 per night for housekeeping. For standard " \
                        "hotels, $2 to $3 per night is common. At upscale or luxury properties, $5 per night is more " \
                        "appropriate. If your room is particularly messy or you have extra requests like additional towels " \
                        "or a rollaway bed, tipping on the higher end acknowledges the additional work."
              },
              {
                question: "Should I tip the bellhop per bag or a flat amount?",
                answer: "The standard practice is to tip $1 to $2 per bag at mid-range hotels and $2 to $5 per bag at " \
                        "luxury properties. If you have only one small bag, a minimum of $2 to $3 is courteous since " \
                        "the bellhop still made the trip to your room. For oversized, heavy, or fragile items that " \
                        "require special handling, tip toward the higher end of the range."
              },
              {
                question: "Do I need to tip the hotel concierge?",
                answer: "Tipping the concierge is not mandatory for simple requests like directions or basic information. " \
                        "However, if the concierge arranges something special like sold-out show tickets, a restaurant " \
                        "reservation at a popular venue, or customized tour planning, a tip of $5 to $20 or more is " \
                        "appropriate depending on the complexity and effort involved."
              },
              {
                question: "How much should I tip for hotel valet parking?",
                answer: "Tip $2 to $5 each time the valet retrieves your car. You do not need to tip when dropping the " \
                        "car off, though an initial $1 to $2 is a nice gesture. At luxury hotels or in high-cost cities, " \
                        "$5 per retrieval is customary. If the valet provides extras like warming up or cooling down your " \
                        "vehicle, the higher end of the range is warranted."
              },
              {
                question: "Should I tip on top of a hotel room service charge?",
                answer: "Many hotels add an automatic service charge or gratuity of 18% to 22% to room service orders. " \
                        "Check the bill carefully before adding more. If a gratuity is already included, an extra $1 to $2 " \
                        "in cash for the delivery person is optional but appreciated. If no gratuity is listed, tip 15% to " \
                        "20% of the food total just as you would at a restaurant."
              }
            ],
            related_slugs: [
              "restaurant-tip-percentage-calculator",
              "taxi-tip-calculator",
              "tipping-etiquette-calculator"
            ],
            base_calculator_slug: "tip-calculator",
            base_calculator_path: :everyday_tip_path
          },
          {
            slug: "taxi-tip-calculator",
            route_name: "programmatic_taxi_tip",
            title: "Taxi & Rideshare Tip Calculator | Calc Hammer",
            h1: "Taxi & Rideshare Tip Calculator",
            meta_description: "Calculate tips for taxi and rideshare drivers. Get fare-based suggestions for Uber, Lyft, and traditional cab rides with distance and service adjustments.",
            intro: "Whether you hail a yellow cab on the street or request an Uber or Lyft through your phone, knowing " \
                   "the right tip amount shows respect for the driver's time and skill. This calculator takes your fare " \
                   "amount and applies standard tipping percentages so you can quickly decide what to leave. It also " \
                   "helps you account for situations that deserve extra generosity, such as heavy traffic navigation, " \
                   "luggage assistance, or trips to the airport at unusual hours.",
            how_it_works: {
              heading: "How the Taxi Tip Calculator Works",
              paragraphs: [
                "Enter the metered fare or the price shown in your rideshare app. The calculator displays what 15%, " \
                "18%, and 20% tips look like on that amount. For traditional taxis, the metered fare before any surcharges " \
                "is the appropriate base. For rideshares, use the fare amount excluding platform fees and taxes.",
                "Factor in the quality of the ride. A driver who took an efficient route, maintained a clean vehicle, " \
                "helped with luggage, or provided a smooth and safe driving experience deserves recognition. The calculator " \
                "lets you adjust percentages upward for these positive factors or stay at the baseline for standard trips.",
                "Review the calculated amounts and round to a convenient number if paying cash. For rideshare apps that " \
                "prompt you to tip after the ride, the suggested amounts displayed by the calculator give you a reference " \
                "point. In the US, 15% to 20% is the accepted range for both taxis and rideshares."
              ]
            },
            example: {
              heading: "Example: Airport Ride with Luggage",
              scenario: "Your taxi fare to the airport is $45, and the driver helped load two heavy suitcases into the trunk.",
              steps: [
                "Enter the fare of $45 into the calculator.",
                "At 20%, the tip comes to $9, bringing the total to $54.",
                "The driver assisted with heavy luggage, so consider 22% to 25% for a $10 to $11.25 tip.",
                "Rounding up to $56 or $57 makes the transaction smooth with cash."
              ]
            },
            tips: [
              "Tip 15% to 20% of the metered taxi fare in the US. For rideshares like Uber and Lyft, the same range applies even though tipping was once less common on those platforms.",
              "If the driver helps with heavy luggage, navigates around a major traffic jam, or waits patiently while you run an errand, add an extra $2 to $5 beyond the standard percentage.",
              "For very short rides under $10, consider a minimum tip of $2 to $3 since the driver still invested time picking you up and the percentage alone may feel insufficient.",
              "International taxi tipping varies widely. In many European cities, rounding up to the nearest euro is sufficient, while in some Asian countries tips are not expected at all."
            ],
            faq: [
              {
                question: "How much should I tip a taxi driver?",
                answer: "In the United States, tipping 15% to 20% of the metered fare is standard for taxi rides. For " \
                        "exceptional service, such as a driver who is especially helpful with directions, luggage, or " \
                        "navigating a complex route, 20% to 25% is a generous gesture. On very short trips, a minimum " \
                        "of $2 to $3 ensures the driver is fairly compensated for their time."
              },
              {
                question: "Should I tip Uber and Lyft drivers?",
                answer: "Yes, tipping rideshare drivers is customary and appreciated. When these services first launched, " \
                        "the no-tipping culture was part of their marketing. Today, both Uber and Lyft include in-app tipping " \
                        "features, and drivers rely on tips as a meaningful part of their income. The standard 15% to 20% " \
                        "range used for traditional taxis applies equally to rideshares."
              },
              {
                question: "Do I tip on the fare before or after surcharges?",
                answer: "Tip on the base fare before tolls, airport surcharges, or peak-hour pricing are added. These " \
                        "additional charges reflect external costs rather than the driver's service quality. By tipping " \
                        "on the base fare, you keep the gratuity proportional to the actual ride and the driver's effort " \
                        "in getting you to your destination safely."
              },
              {
                question: "Is it better to tip my taxi driver in cash?",
                answer: "Cash tips are generally preferred by taxi drivers because they receive the money immediately without " \
                        "credit card processing delays or fees. However, if you do not have cash, tipping via card is perfectly " \
                        "acceptable and far better than leaving no tip at all. For rideshare drivers, the in-app tip is the " \
                        "most convenient method and is reliably delivered to the driver."
              },
              {
                question: "How much do I tip for a long-distance taxi ride?",
                answer: "For rides over $50, a percentage-based tip of 15% to 20% remains appropriate. On very long trips " \
                        "exceeding $100, some riders feel comfortable dropping to 10% to 15% since the dollar amount is " \
                        "already substantial. Consider the driver's effort: a two-hour highway drive requires sustained " \
                        "attention and the driver must return empty, so lean toward the higher end."
              }
            ],
            related_slugs: [
              "delivery-tip-percentage-calculator",
              "hotel-tip-calculator",
              "tipping-etiquette-calculator"
            ],
            base_calculator_slug: "tip-calculator",
            base_calculator_path: :everyday_tip_path
          },
          {
            slug: "buffet-tip-calculator",
            route_name: "programmatic_buffet_tip",
            title: "Buffet Tip Calculator | How Much to Tip | Calc Hammer",
            h1: "Buffet Tip Calculator",
            meta_description: "Calculate how much to tip at a buffet restaurant. Get recommendations based on the level of service, drink refills, and table maintenance provided.",
            intro: "Buffet restaurants present a unique tipping dilemma. You serve yourself from the food stations, but " \
                   "there is usually a server who brings your drinks, clears your plates, and keeps your table clean. " \
                   "Because the service level falls somewhere between full table service and complete self-service, the " \
                   "expected tip is lower than at a traditional sit-down restaurant but not zero. This calculator helps " \
                   "you land on the right amount based on the service you actually received.",
            how_it_works: {
              heading: "How the Buffet Tip Calculator Works",
              paragraphs: [
                "Enter the total bill for your buffet meal. The calculator applies buffet-specific tip percentages of " \
                "10%, 12%, and 15%, which are lower than full-service restaurant rates because you handle your own food " \
                "selection and plating. These rates reflect the reduced but still real service your server provides.",
                "Consider what your server actually did during the meal. If they kept your drinks refilled promptly, " \
                "cleared plates between trips to the buffet, brought extra napkins or condiments, and maintained a " \
                "clean and pleasant table, the higher end of the range is warranted and the calculator reflects this.",
                "Review the calculated amounts alongside the per-person breakdown if you are dining with a group. " \
                "Even though the tip percentage is lower than at full-service restaurants, the total can still be " \
                "meaningful, especially for large parties that generate significant clearing and drink-refill work."
              ]
            },
            example: {
              heading: "Example: Family Buffet Lunch",
              scenario: "A family of four visits a buffet restaurant with a total bill of $60. The server refilled drinks three times and promptly cleared plates.",
              steps: [
                "Enter the buffet bill of $60 with a party size of 4.",
                "At 10%, the tip is $6 ($1.50 per person) for minimal service.",
                "The server was attentive with drinks and clearing, so 15% yields $9 ($2.25 per person).",
                "The family settles on $9 to $10 as a fair reflection of the solid service received."
              ]
            },
            tips: [
              "A 10% to 15% tip is the standard range at buffet restaurants in the US since the server handles drinks and clearing rather than full food service and order taking.",
              "If the buffet server goes beyond basics by recommending dishes, bringing special sauces from the kitchen, or accommodating dietary needs, tip closer to 15% or even 18%.",
              "At high-end buffets such as those at Las Vegas casinos or upscale brunch spots, tipping 15% to 18% is more common because the overall experience and pricing reflect premium service.",
              "If you dine at a fully self-service buffet with no assigned server and you bus your own table, tipping is not expected, though leaving a dollar or two is a kind gesture."
            ],
            faq: [
              {
                question: "Do you tip at a buffet restaurant?",
                answer: "Yes, tipping at a buffet where a server is assigned to your table is expected in the United States. " \
                        "Even though you serve yourself the food, the server refills your beverages, clears used plates, " \
                        "resets silverware, and ensures your dining area stays clean. A tip of 10% to 15% of the bill " \
                        "acknowledges their work and is the accepted norm."
              },
              {
                question: "Why is the buffet tip lower than at a regular restaurant?",
                answer: "At a full-service restaurant, the server takes your order, communicates with the kitchen, delivers " \
                        "multiple courses, and manages timing. At a buffet, you handle food selection and plating yourself. " \
                        "The server's responsibilities are limited to beverages, clearing, and table maintenance. The lower " \
                        "tip percentage of 10% to 15% reflects this reduced but still valuable scope of service."
              },
              {
                question: "Should I tip at an all-you-can-eat sushi restaurant?",
                answer: "All-you-can-eat sushi restaurants typically involve more server interaction than a standard buffet " \
                        "because the server takes your order rounds and delivers dishes to the table. This model is closer " \
                        "to full table service, so a tip of 15% to 18% is appropriate. The server is doing meaningful " \
                        "work coordinating your orders with the kitchen throughout the meal."
              },
              {
                question: "How do I tip at a breakfast buffet in a hotel?",
                answer: "If the hotel breakfast buffet has a server who brings coffee, juice, and clears your plates, tip " \
                        "$2 to $5 per person or 10% to 15% of what the meal would cost if it were not included in your " \
                        "room rate. If the buffet is entirely self-service with no server interaction and you clear your " \
                        "own dishes, tipping is not necessary but a small cash gesture is appreciated."
              },
              {
                question: "Do I tip on the full buffet price even if I did not eat much?",
                answer: "Yes, the tip should be based on the amount you were charged, not on how much food you consumed. " \
                        "The server performed the same duties regardless of your appetite. They refilled your drinks, " \
                        "cleared your plates, and maintained your table area. The bill total is the fairest basis for " \
                        "calculating the tip since it reflects the service commitment to your table."
              }
            ],
            related_slugs: [
              "restaurant-tip-percentage-calculator",
              "tipping-etiquette-calculator",
              "delivery-tip-percentage-calculator"
            ],
            base_calculator_slug: "tip-calculator",
            base_calculator_path: :everyday_tip_path
          },
          {
            slug: "tipping-etiquette-calculator",
            route_name: "programmatic_tipping_etiquette",
            title: "Tipping Etiquette Calculator for All Services",
            h1: "Tipping Etiquette Calculator",
            meta_description: "All-in-one tipping guide and calculator for restaurants, delivery, hotels, taxis, salons, movers, and more. Find the right tip for any service situation.",
            intro: "Tipping customs can feel like an unwritten rulebook that changes depending on the service, the setting, " \
                   "and even the country you are in. This comprehensive calculator covers all major tipping scenarios " \
                   "in one place. From restaurant servers and baristas to movers and hairstylists, enter your bill or " \
                   "service cost and get clear recommendations tailored to each profession. Stop guessing and start " \
                   "tipping with confidence no matter the situation.",
            how_it_works: {
              heading: "How the Tipping Etiquette Calculator Works",
              paragraphs: [
                "Choose the type of service from the menu of options. Each service category has its own recommended " \
                "percentage range based on US tipping norms. The calculator covers restaurants, delivery drivers, " \
                "hotel staff, taxi and rideshare drivers, hair stylists, baristas, movers, and several other common services.",
                "Enter the cost of the service or your bill total. The calculator applies the category-specific " \
                "percentage range and shows the suggested tip in dollars. Where flat-rate tips are more appropriate, " \
                "such as for hotel bellhops or coat check attendants, the calculator shows a per-item or per-instance " \
                "recommendation instead of a percentage.",
                "Review the context notes alongside each calculation. These notes explain why a particular range exists, " \
                "how to adjust for quality of service, and what the norms look like in other countries. This educational " \
                "layer helps you build lasting tipping intuition rather than relying on the calculator every single time."
              ]
            },
            example: {
              heading: "Example: Wedding Weekend Tipping Budget",
              scenario: "You are attending a wedding weekend and need tips for a hotel stay, two taxi rides, a hair appointment, and a restaurant dinner.",
              steps: [
                "Hotel housekeeping for 2 nights at $5 per night: $10. Bellhop for 2 bags: $4 to $6.",
                "Two taxi rides at $25 each with 20% tips: $10 total in taxi tips.",
                "Hair styling at $80 with a 20% tip: $16.",
                "Your total weekend tipping budget is approximately $40 to $42, planned in advance."
              ]
            },
            tips: [
              "Keep small bills on hand when traveling so you are always prepared to tip hotel housekeeping, bellhops, valets, and other service staff who are best tipped in cash.",
              "When unsure about the right tip amount for an uncommon service, 15% to 20% of the total cost is a safe starting point that works across most US service industries.",
              "Research tipping customs before traveling internationally. In Australia and much of Asia, tipping is not expected. In Europe, rounding up or leaving 5% to 10% is typical.",
              "For services where you build an ongoing relationship, like a regular hairstylist or barber, consistent generous tipping helps maintain priority booking and personalized attention."
            ],
            faq: [
              {
                question: "What services require tipping in the United States?",
                answer: "In the US, tipping is customary for restaurant servers, bartenders, delivery drivers, taxi and " \
                        "rideshare drivers, hotel housekeeping, bellhops, valets, hair stylists, barbers, spa therapists, " \
                        "movers, and tour guides. The common thread is that many of these workers earn a lower base wage " \
                        "with the expectation that tips will supplement their income to a livable level."
              },
              {
                question: "How much should I tip my hairstylist or barber?",
                answer: "The standard tip for a hairstylist or barber is 15% to 20% of the total service cost before any " \
                        "product purchases. If you received a complex service like color treatment, highlights, or a " \
                        "corrective cut, tipping 20% to 25% acknowledges the extra skill and time involved. For a simple " \
                        "trim, 15% to 20% is perfectly appropriate and appreciated."
              },
              {
                question: "Do I tip the owner of a salon or business?",
                answer: "Traditionally, you did not tip the owner of a salon or other service business, since they set the " \
                        "prices and keep the profits. However, this norm has shifted in recent years, and it is now common " \
                        "to tip the owner the same as any other stylist. When in doubt, offer the tip and let the owner " \
                        "accept or decline as they see fit."
              },
              {
                question: "How much should I tip movers?",
                answer: "For professional movers, tip $20 to $40 per mover for a half-day job and $40 to $60 per mover " \
                        "for a full-day move. If the move involved stairs, heavy or fragile items, extreme heat, or " \
                        "other difficult conditions, tip on the higher end. You can give the tip in cash directly to " \
                        "each mover at the end of the job to ensure each person receives their share."
              },
              {
                question: "Should I tip at a coffee shop or for counter service?",
                answer: "Tipping at coffee shops and counter-service establishments is optional but increasingly common. " \
                        "For a simple drip coffee, tipping is not expected, but $0.50 to $1 is a kind gesture. For " \
                        "handcrafted espresso drinks that require skill and time, $1 to $2 or 10% to 15% is appropriate. " \
                        "Digital tip prompts at point-of-sale terminals have made these tips more visible and frequent."
              }
            ],
            related_slugs: [
              "restaurant-tip-percentage-calculator",
              "hotel-tip-calculator",
              "taxi-tip-calculator"
            ],
            base_calculator_slug: "tip-calculator",
            base_calculator_path: :everyday_tip_path
          }
        ]
      }.freeze
    end
  end
end
