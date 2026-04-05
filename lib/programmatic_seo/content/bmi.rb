module ProgrammaticSeo
  module Content
    module Bmi
      DEFINITION = {
        base_key: "bmi",
        category: "health",
        stimulus_controller: "bmi-calculator",
        form_partial: "programmatic/forms/bmi",
        icon_path: "M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z",
        expansions: [
          {
            slug: "bmi-for-women-calculator",
            route_name: "programmatic_bmi_for_women",
            title: "BMI Calculator for Women - Free Health Tool",
            h1: "BMI Calculator for Women",
            meta_description: "Calculate your Body Mass Index with women-specific health interpretations. Understand how BMI relates to body fat percentage and health risks for women.",
            intro: "Body Mass Index affects women differently than men due to naturally higher body fat percentages and different fat distribution patterns. Women typically carry 6-11% more body fat than men at the same BMI. This calculator provides the standard BMI formula alongside context that helps women interpret their results more accurately, accounting for factors like age, muscle mass, and reproductive health considerations.",
            how_it_works: {
              heading: "How BMI Works for Women",
              paragraphs: [
                "BMI is calculated the same way for everyone: weight in kilograms divided by height in meters squared. However, women naturally carry more essential body fat than men, which means a BMI of 25 may represent different health profiles for each sex. The WHO categories remain the same, but the clinical interpretation benefits from gender-specific context.",
                "For women, body fat percentage at a given BMI tends to be higher than for men. A woman with a BMI of 22 typically has 25-30% body fat, while a man at the same BMI averages 18-23%. This difference is biological and healthy, driven by essential fat stores related to hormonal function and reproductive health.",
                "Research shows that waist circumference is an important complement to BMI for women. A waist measurement above 35 inches (88 cm) indicates elevated health risk regardless of BMI category. Combining both measurements gives a more complete picture of weight-related health status than either metric alone."
              ]
            },
            example: {
              heading: "Example Calculation",
              scenario: "A woman who is 5 feet 5 inches (165 cm) tall and weighs 145 pounds (65.8 kg).",
              steps: [
                "Convert measurements: 65.8 kg and 1.65 m",
                "BMI = 65.8 / (1.65 x 1.65) = 65.8 / 2.7225 = 24.2",
                "Classification: Normal weight (18.5-24.9 range)",
                "For a woman of this height, the healthy weight range is approximately 111-150 lbs (50-68 kg)"
              ]
            },
            tips: [
              "Women's BMI naturally fluctuates 1-2 points during the menstrual cycle due to water retention, so measure consistently at the same cycle phase.",
              "After menopause, body fat redistribution toward the abdomen increases health risk even if BMI stays the same. Track waist circumference as well.",
              "Pregnancy invalidates BMI calculations entirely. Use pregnancy-specific weight gain guidelines from your healthcare provider instead.",
              "Athletic women with significant muscle mass may show an elevated BMI despite having healthy body fat levels. Consider a body composition test for accuracy."
            ],
            faq: [
              {
                question: "What is a healthy BMI range for women?",
                answer: "The standard healthy BMI range is 18.5 to 24.9 for both sexes. However, some researchers suggest that women may have slightly different optimal ranges depending on age. Women over 65 may benefit from a BMI in the 25-27 range, as slightly higher weight is associated with better outcomes in older adults."
              },
              {
                question: "Why do women have higher body fat at the same BMI?",
                answer: "Women carry more essential body fat for hormonal regulation, reproductive function, and breast tissue. This sex-specific fat comprises about 10-13% of a woman's total body weight compared to 2-5% for men. It is biologically normal and healthy, which is why the same BMI number represents different body compositions between sexes."
              },
              {
                question: "Does BMI change during pregnancy?",
                answer: "BMI should not be used during pregnancy as a health indicator. Weight gain during pregnancy is expected and necessary. Pre-pregnancy BMI helps determine recommended weight gain ranges: 25-35 lbs for normal weight, 15-25 lbs for overweight, and 11-20 lbs for obese pre-pregnancy BMI. Consult your OB/GYN for personalized guidance."
              },
              {
                question: "Is BMI accurate for women over 50?",
                answer: "BMI becomes less reliable after menopause because women tend to lose muscle mass and gain visceral fat while their weight may remain stable. A normal BMI can mask unhealthy body composition changes. Supplementing BMI with waist circumference measurement and, ideally, a DEXA scan for body composition gives a more accurate health assessment for older women."
              },
              {
                question: "How does birth control affect BMI?",
                answer: "Hormonal birth control may cause modest weight changes in some women, typically 2-5 pounds of water retention in the first few months. This can shift BMI by 0.3-0.8 points. These changes usually stabilize within 3-6 months. Long-term studies show no significant difference in weight gain between hormonal contraceptive users and non-users."
              }
            ],
            related_slugs: ["bmi-for-men-calculator", "healthy-weight-range-calculator", "overweight-check-calculator"],
            base_calculator_slug: "bmi-calculator",
            base_calculator_path: :health_bmi_path
          },
          {
            slug: "bmi-for-men-calculator",
            route_name: "programmatic_bmi_for_men",
            title: "BMI Calculator for Men - Free Health Tool",
            h1: "BMI Calculator for Men",
            meta_description: "Calculate your BMI with male-specific health context. Understand how muscle mass, age, and body composition affect BMI interpretation for men.",
            intro: "Men tend to carry less body fat and more muscle mass than women at identical BMI values, which can make the standard BMI categories misleading for physically active males. This calculator provides the standard BMI result alongside male-specific context, helping you understand whether your number truly reflects your health status or is skewed by muscle mass and frame size.",
            how_it_works: {
              heading: "How BMI Applies to Men",
              paragraphs: [
                "The BMI formula divides weight by height squared, producing a single number that categorizes you as underweight, normal, overweight, or obese. For sedentary men, these categories correlate reasonably well with body fat percentage and health risk. The challenge arises with men who carry significant muscle mass, which weighs more than fat per unit volume.",
                "Men typically have 15-20% body fat at a BMI of 25, compared to 25-30% for women at the same number. This means a man classified as overweight by BMI may actually have a healthy body composition if his excess weight comes from muscle rather than fat. Waist circumference below 40 inches is a useful complementary check.",
                "For men, visceral fat accumulation around the midsection poses the greatest health risk. Unlike subcutaneous fat under the skin, visceral fat surrounds internal organs and drives metabolic disease. A man with a normal BMI but a large waist measurement may face higher health risks than one with an elevated BMI and a trim waistline."
              ]
            },
            example: {
              heading: "Example Calculation",
              scenario: "A man who is 5 feet 10 inches (178 cm) tall and weighs 185 pounds (83.9 kg).",
              steps: [
                "Convert measurements: 83.9 kg and 1.78 m",
                "BMI = 83.9 / (1.78 x 1.78) = 83.9 / 3.1684 = 26.5",
                "Classification: Overweight (25.0-29.9 range)",
                "For a man who strength trains regularly, this BMI may overstate fat-related risk. A waist circumference under 40 inches would support a healthy assessment."
              ]
            },
            tips: [
              "Men who lift weights regularly should supplement BMI with waist-to-height ratio. A ratio below 0.5 indicates healthy abdominal fat levels regardless of BMI.",
              "Testosterone levels affect body composition significantly. Low testosterone can increase body fat percentage even at a stable BMI, particularly after age 40.",
              "Measure BMI in the morning before eating for the most consistent results. Body weight can fluctuate 2-5 pounds throughout the day from food and fluid intake.",
              "If your BMI is in the overweight range but you exercise regularly and have a waist under 40 inches, focus on fitness metrics rather than weight loss."
            ],
            faq: [
              {
                question: "What is a good BMI for men?",
                answer: "The healthy BMI range is 18.5-24.9 for men. However, many fit men with moderate muscle mass fall in the 25-27 range without elevated health risk. Research suggests that mortality risk for men is lowest in the 22-25 BMI range for sedentary individuals and 25-28 for those who strength train regularly."
              },
              {
                question: "Can muscle mass make BMI inaccurate for men?",
                answer: "Yes, BMI cannot distinguish between muscle and fat weight. A muscular man at 6 feet tall and 210 pounds has a BMI of 28.5, classified as overweight, yet may have only 12% body fat. This is particularly common in athletes, military personnel, and regular weightlifters. Body fat measurement or waist circumference provides better accuracy."
              },
              {
                question: "At what BMI should men be concerned?",
                answer: "A BMI above 30 is classified as obese and carries increased risk for heart disease, type 2 diabetes, and joint problems regardless of muscle mass. Between 25-30, risk depends on other factors: waist circumference, blood pressure, cholesterol levels, and physical activity. Below 18.5 raises concerns about malnutrition or underlying illness."
              },
              {
                question: "Does BMI change with age for men?",
                answer: "Men naturally lose muscle mass at about 3-5% per decade after age 30, a process called sarcopenia. This means BMI may stay stable or even decrease while body fat percentage increases. Men over 50 should consider body composition testing rather than relying solely on BMI to track health status over time."
              },
              {
                question: "How does beer belly affect BMI accuracy?",
                answer: "A beer belly indicates visceral fat accumulation, which is the most dangerous type of fat for metabolic health. BMI alone cannot detect this pattern. A man with a normal BMI of 24 but a waist measurement over 40 inches carries higher cardiovascular risk than someone with a BMI of 27 and a 34-inch waist. Always measure both."
              }
            ],
            related_slugs: ["bmi-for-women-calculator", "bmi-for-athletes-calculator", "healthy-weight-range-calculator"],
            base_calculator_slug: "bmi-calculator",
            base_calculator_path: :health_bmi_path
          },
          {
            slug: "bmi-for-athletes-calculator",
            route_name: "programmatic_bmi_for_athletes",
            title: "BMI Calculator for Athletes - Free Tool",
            h1: "BMI Calculator for Athletes",
            meta_description: "Calculate your BMI with athlete-specific context. Learn why standard BMI categories can be misleading for muscular and trained individuals.",
            intro: "Standard BMI categories were developed for sedentary populations and frequently misclassify athletes as overweight or obese despite excellent fitness levels. Many professional football players, sprinters, and bodybuilders have BMIs above 30 with body fat percentages under 15%. This calculator provides your standard BMI alongside guidance on why athletes need additional metrics to assess their body composition accurately.",
            how_it_works: {
              heading: "Why BMI Fails for Athletes",
              paragraphs: [
                "BMI treats all weight equally, making no distinction between muscle, fat, bone density, and water. Athletes who train intensively develop higher muscle mass, denser bones, and greater glycogen stores, all of which increase weight without increasing health risk. A sprinter and an office worker at the same height and weight have vastly different body compositions.",
                "The degree of BMI inaccuracy depends on the sport. Endurance athletes like marathon runners typically have BMIs in the normal range and accurate classifications. Strength and power athletes — football linemen, wrestlers, weightlifters — are most likely to be misclassified. Mixed-sport athletes fall somewhere in between, depending on their training emphasis.",
                "For athletes, body fat percentage is a far more useful metric. Elite male athletes typically maintain 6-13% body fat, while elite female athletes range from 14-20%. Hydrostatic weighing, DEXA scans, and skinfold measurements all provide better body composition data than BMI for anyone engaged in regular resistance training."
              ]
            },
            example: {
              heading: "Example Calculation",
              scenario: "A college football running back who is 5 feet 11 inches (180 cm) and weighs 215 pounds (97.5 kg) with 11% body fat.",
              steps: [
                "BMI = 97.5 / (1.80 x 1.80) = 97.5 / 3.24 = 30.1",
                "Classification: Obese Class I (30.0-34.9 range)",
                "Actual body fat: 11% — well within elite athlete range",
                "This demonstrates the BMI limitation: the classification suggests obesity while the athlete is in exceptional physical condition"
              ]
            },
            tips: [
              "Use the Fat-Free Mass Index (FFMI) instead of BMI. FFMI values above 25 suggest significant muscular development that invalidates standard BMI categories.",
              "Track body fat percentage quarterly using the same measurement method each time. Consistency in method matters more than the absolute accuracy of any single technique.",
              "Off-season weight gain of 5-10 pounds is normal for many athletes. Assess composition changes rather than reacting to BMI fluctuations tied to training cycles.",
              "Sports-specific body composition standards are more relevant than general BMI charts. Consult your team nutritionist or sports medicine physician for appropriate targets."
            ],
            faq: [
              {
                question: "What BMI do most professional athletes have?",
                answer: "It varies enormously by sport. NBA players average a BMI of 25-27. NFL linemen range from 35-45. Marathoners average 19-21. Gymnasts tend toward 20-22. Swimmers average 22-24. These numbers illustrate why a single BMI cutoff cannot meaningfully assess health across different athletic populations."
              },
              {
                question: "Should athletes ignore BMI completely?",
                answer: "Not entirely, but it should not be the primary metric. BMI can flag significant weight changes that warrant investigation. An athlete whose BMI increases 3-4 points without corresponding training changes should assess whether the gain is muscle or fat. BMI serves as a screening trigger, not a diagnostic tool for trained individuals."
              },
              {
                question: "What body fat percentage is healthy for athletes?",
                answer: "For male athletes, 6-17% is typical depending on sport, with power sports on the lower end and endurance sports slightly higher. Female athletes generally maintain 14-25%. Going below essential fat levels — roughly 3-5% for men and 10-13% for women — impairs performance and health, particularly hormonal function and bone density."
              },
              {
                question: "Does BMI accuracy improve after retiring from sport?",
                answer: "Yes, BMI becomes more accurate as muscle mass decreases after retirement from competitive training. Former athletes who stop training often experience significant body composition changes within 2-3 years. Monitoring BMI becomes more useful during this transition, especially combined with waist circumference to track fat redistribution."
              },
              {
                question: "Can two athletes at the same BMI have very different fitness?",
                answer: "Absolutely. A 6-foot, 200-pound powerlifter and a 6-foot, 200-pound untrained individual both have a BMI of 27.1. The powerlifter might have 12% body fat and excellent cardiovascular markers, while the untrained person might have 28% body fat and elevated blood pressure. BMI reveals nothing about composition or fitness level."
              }
            ],
            related_slugs: ["bmi-for-men-calculator", "bmi-for-women-calculator", "healthy-weight-range-calculator"],
            base_calculator_slug: "bmi-calculator",
            base_calculator_path: :health_bmi_path
          },
          {
            slug: "bmi-for-seniors-calculator",
            route_name: "programmatic_bmi_for_seniors",
            title: "BMI Calculator for Seniors (65+) - Free Tool",
            h1: "BMI Calculator for Seniors",
            meta_description: "Calculate your BMI with age-adjusted interpretation for adults over 65. Learn why slightly higher BMI may be protective in older adults.",
            intro: "BMI interpretation changes significantly after age 65. Research consistently shows that older adults with BMIs in the 25-27 range have lower mortality rates than those in the traditional normal range of 18.5-24.9. This phenomenon, sometimes called the obesity paradox, means the standard weight categories may not apply to seniors. This calculator provides age-appropriate context for your BMI result.",
            how_it_works: {
              heading: "How BMI Differs for Older Adults",
              paragraphs: [
                "After 65, body composition shifts substantially even without weight change. Muscle mass declines through sarcopenia while fat mass increases, meaning a stable BMI can mask deteriorating body composition. Height also decreases due to spinal compression, artificially increasing BMI by 1-2 points over a decade without any actual weight gain.",
                "Multiple large studies have found that the lowest mortality risk for adults over 65 falls in the BMI range of 25-27, which is classified as overweight under standard guidelines. Being underweight (BMI below 22 for seniors) carries significantly higher risk than being moderately overweight, primarily due to reduced reserves during illness and recovery.",
                "For seniors, unintentional weight loss is a more important health signal than BMI category. Losing more than 5% of body weight over 6-12 months without trying warrants medical investigation regardless of starting BMI. Maintaining stable weight and muscle mass through adequate protein intake and resistance exercise is the priority."
              ]
            },
            example: {
              heading: "Example Calculation",
              scenario: "A 72-year-old woman who is 5 feet 3 inches (160 cm) tall and weighs 155 pounds (70.3 kg).",
              steps: [
                "BMI = 70.3 / (1.60 x 1.60) = 70.3 / 2.56 = 27.5",
                "Standard classification: Overweight",
                "Age-adjusted interpretation: Within the optimal range for adults over 65 (25-27 BMI)",
                "This BMI provides healthy reserves for illness recovery while not reaching obesity-associated risk levels"
              ]
            },
            tips: [
              "Weigh yourself weekly at the same time to detect unintentional weight loss early. A downward trend of 5% or more over six months warrants a doctor visit.",
              "Prioritize protein intake of 1.0-1.2 grams per kilogram of body weight daily to slow muscle loss. This is higher than the standard adult recommendation.",
              "Resistance exercises like chair squats and wall pushups help preserve muscle mass, which improves BMI accuracy by maintaining the muscle-to-fat ratio.",
              "If your height has decreased, recalculate BMI with your current measured height rather than the height recorded years ago on your medical chart."
            ],
            faq: [
              {
                question: "What is a healthy BMI for people over 65?",
                answer: "Research suggests the optimal BMI range for adults over 65 is 25-27, slightly higher than the standard 18.5-24.9 range. This modest overweight classification appears protective, providing energy reserves during illness, reducing fracture risk, and correlating with lower all-cause mortality compared to both lower and higher BMI ranges."
              },
              {
                question: "Why is being underweight more dangerous for seniors?",
                answer: "Underweight seniors have fewer nutritional reserves to draw on during hospitalization, surgery, or acute illness. Low BMI in older adults is associated with weaker immune function, slower wound healing, greater bone fracture risk, and higher rates of infection. Studies show underweight seniors have 2-3 times higher mortality risk than those in the overweight category."
              },
              {
                question: "Should seniors try to lose weight?",
                answer: "Weight loss in seniors requires careful medical supervision because it often involves losing muscle along with fat, worsening sarcopenia. If weight loss is medically indicated for conditions like severe obesity or diabetes management, it should emphasize preserving muscle through high protein intake and resistance exercise rather than aggressive caloric restriction."
              },
              {
                question: "How does height loss affect BMI in older adults?",
                answer: "Spinal compression and osteoporosis can reduce height by 1-3 inches over decades. Since BMI divides weight by height squared, even a one-inch height loss increases calculated BMI by approximately 1 point without any weight change. Always use current measured height rather than historical records for an accurate BMI calculation."
              },
              {
                question: "Does BMI predict health outcomes in nursing home residents?",
                answer: "For nursing home residents, BMI has limited predictive value because frailty, functional status, and nutritional intake matter more. Very low BMI (under 20) strongly predicts poor outcomes in this population. Moderate BMI levels between 25-30 are associated with better survival rates. Functional assessments like grip strength and walking speed provide better health indicators."
              }
            ],
            related_slugs: ["bmi-for-women-calculator", "bmi-for-men-calculator", "overweight-check-calculator"],
            base_calculator_slug: "bmi-calculator",
            base_calculator_path: :health_bmi_path
          },
          {
            slug: "healthy-weight-range-calculator",
            route_name: "programmatic_healthy_weight_range",
            title: "Healthy Weight Range Calculator - Free Tool",
            h1: "Healthy Weight Range Calculator",
            meta_description: "Find your healthy weight range based on height. Calculate the minimum and maximum weights for a healthy BMI between 18.5 and 24.9.",
            intro: "Rather than focusing on a single ideal weight, medical professionals recommend maintaining weight within a healthy range. This calculator determines the weight range that corresponds to a BMI of 18.5-24.9 for your height, giving you a target window rather than an unrealistic single number. Understanding your range helps set achievable goals and reduces fixation on arbitrary weight targets.",
            how_it_works: {
              heading: "How the Healthy Weight Range Is Calculated",
              paragraphs: [
                "The healthy weight range derives directly from the BMI formula. For a given height, the minimum healthy weight corresponds to a BMI of 18.5 and the maximum corresponds to 24.9. The calculation reverses the BMI formula: weight equals BMI multiplied by height in meters squared. This produces a range, typically spanning 30-45 pounds depending on height.",
                "The range widens as height increases. A person who is 5 feet tall has a healthy range of about 95-128 pounds, a span of 33 pounds. A person who is 6 feet tall has a range of approximately 136-184 pounds, a span of 48 pounds. This is because the BMI formula scales with the square of height, amplifying the range for taller individuals.",
                "Where you fall within the healthy range depends on factors like frame size, muscle mass, age, and sex. Someone with a large skeletal frame and moderate muscle mass may be healthiest near the top of the range, while a small-framed sedentary person may feel best near the middle. There is no single correct weight within the range."
              ]
            },
            example: {
              heading: "Example Calculation",
              scenario: "A person who is 5 feet 7 inches (170 cm) tall.",
              steps: [
                "Height in meters: 1.70 m, height squared: 2.89 m²",
                "Minimum healthy weight: 18.5 x 2.89 = 53.5 kg (118 lbs)",
                "Maximum healthy weight: 24.9 x 2.89 = 72.0 kg (159 lbs)",
                "Healthy weight range: 118 to 159 lbs — a 41-pound window within which BMI is classified as normal"
              ]
            },
            tips: [
              "Aim for the middle of your range rather than the extremes. Being consistently at either boundary provides less buffer against natural weight fluctuations.",
              "Frame size matters. Measure your wrist circumference to estimate frame size — smaller frames tend toward the lower end of the range, larger frames toward the upper end.",
              "Weight within the healthy range that you can maintain without extreme dietary restriction is likely your personal ideal. Sustainable weight is healthier than a forced lower number.",
              "Seasonal weight fluctuations of 3-7 pounds are normal. Do not adjust your habits unless your weight consistently drifts outside the healthy range."
            ],
            faq: [
              {
                question: "What is the healthy weight range for my height?",
                answer: "The healthy weight range corresponds to a BMI of 18.5-24.9. For common heights: 5'0\" is 95-128 lbs, 5'4\" is 108-145 lbs, 5'8\" is 122-164 lbs, 6'0\" is 136-184 lbs, and 6'4\" is 152-204 lbs. Enter your exact height in the calculator above for a precise range personalized to you."
              },
              {
                question: "Is the healthy weight range the same for men and women?",
                answer: "The BMI-based weight range is the same for both sexes at a given height. However, ideal weight within that range differs because men typically have more muscle mass and denser bones. Men often feel best in the upper half of the range while women may be comfortable anywhere within it, depending on build and activity level."
              },
              {
                question: "What if I am slightly outside the healthy range?",
                answer: "Being 5-10 pounds outside the range in either direction rarely indicates a significant health problem. The boundaries at 18.5 and 24.9 BMI are statistical cutoffs, not precise thresholds. If you are slightly above the range with good blood pressure, cholesterol, and blood sugar levels, your weight is likely fine. Consult your doctor for personalized assessment."
              },
              {
                question: "Does the healthy weight range change with age?",
                answer: "The standard BMI-based range does not officially change with age, but research suggests older adults (65+) may benefit from being in the upper portion of the range or slightly above it. Younger adults in their twenties and thirties tend to have the best health outcomes near the middle of the range. Age-appropriate targets should be discussed with a healthcare provider."
              },
              {
                question: "How accurate is a weight range based on BMI?",
                answer: "For 80-85% of the population, the BMI-based weight range accurately identifies a healthy weight zone. It is less accurate for very muscular individuals, very tall or very short people, and certain ethnic groups with different body composition averages. Despite these limitations, it remains the most practical population-level screening tool available."
              }
            ],
            related_slugs: ["bmi-for-women-calculator", "bmi-for-men-calculator", "overweight-check-calculator"],
            base_calculator_slug: "bmi-calculator",
            base_calculator_path: :health_bmi_path
          },
          {
            slug: "overweight-check-calculator",
            route_name: "programmatic_overweight_check",
            title: "Overweight Check Calculator - Free BMI Test",
            h1: "Am I Overweight? Quick BMI Check",
            meta_description: "Quick overweight assessment using BMI. Enter your height and weight for an instant check of whether you fall in the overweight or obese range.",
            intro: "This is a quick, no-frills tool for the most common BMI question: am I overweight? Enter your height and weight to get an immediate yes-or-no answer along with your exact BMI number and how far you are from the overweight threshold. No lengthy explanations needed — just a fast check with clear results and straightforward next steps if action is warranted.",
            how_it_works: {
              heading: "How the Overweight Check Works",
              paragraphs: [
                "The calculator computes your BMI and compares it against the WHO overweight threshold of 25.0. If your BMI is 25.0 or above, you are classified as overweight. At 30.0 or above, the classification becomes obese. The tool shows exactly how many BMI points you are above or below the threshold, making it easy to understand your position relative to the cutoff.",
                "Being overweight by BMI does not automatically mean you are unhealthy. About one-third of people classified as overweight by BMI have normal metabolic markers: healthy blood pressure, cholesterol, blood sugar, and inflammatory levels. These individuals, sometimes described as metabolically healthy overweight, may not benefit from weight loss intervention.",
                "The tool also calculates how many pounds you would need to lose to reach a BMI of 24.9, the upper boundary of normal weight. This gives a concrete target if you decide weight loss is appropriate. However, even a 5-10% reduction from your current weight provides meaningful health benefits without needing to reach normal BMI."
              ]
            },
            example: {
              heading: "Example Calculation",
              scenario: "A person who is 5 feet 9 inches (175 cm) tall and weighs 195 pounds (88.5 kg).",
              steps: [
                "BMI = 88.5 / (1.75 x 1.75) = 88.5 / 3.0625 = 28.9",
                "Result: Yes, overweight — BMI is 3.9 points above the 25.0 threshold",
                "Weight to reach normal BMI: 24.9 x 3.0625 = 76.3 kg (168 lbs), so approximately 27 lbs above normal range",
                "A 5-10% weight reduction (10-20 lbs) would provide significant health benefits even without reaching normal BMI"
              ]
            },
            tips: [
              "If your BMI is between 25 and 27, focus on lifestyle changes before considering it a serious concern. Many people in this range are metabolically healthy.",
              "A BMI above 30 warrants a conversation with your doctor, especially if you have a family history of diabetes, heart disease, or high blood pressure.",
              "Rapid weight loss of more than 2 pounds per week is counterproductive. Slower loss of 0.5-1 pound per week preserves muscle and is more likely to be sustained.",
              "Check your result in context: measure your waist circumference too. A waist over 40 inches for men or 35 inches for women adds independent risk regardless of BMI."
            ],
            faq: [
              {
                question: "At what BMI am I considered overweight?",
                answer: "A BMI of 25.0 or higher is classified as overweight. The overweight category spans from 25.0 to 29.9. At 30.0 and above, the classification becomes obese, which is further divided into Class I (30-34.9), Class II (35-39.9), and Class III (40+). Each higher class is associated with progressively greater health risk."
              },
              {
                question: "Can I be overweight by BMI but still healthy?",
                answer: "Yes. Research identifies a subset of overweight individuals who are metabolically healthy, meaning they have normal blood pressure, blood sugar, cholesterol, and insulin levels. These individuals may not benefit from weight loss. However, this metabolically healthy overweight status can change over time, so regular health screenings remain important."
              },
              {
                question: "How much weight do I need to lose to not be overweight?",
                answer: "The calculator shows exactly how many pounds separate you from a BMI of 24.9. As a rough guide, each BMI point above 25 represents approximately 5-8 pounds depending on height. However, losing even 5-10% of current body weight provides clinically meaningful health improvements, even if you remain technically in the overweight BMI category."
              },
              {
                question: "Is being slightly overweight really dangerous?",
                answer: "For most people, a BMI of 25-27 carries minimal additional health risk compared to normal weight. Risk increases more significantly above BMI 28-30, especially when combined with other factors like sedentary lifestyle, high blood pressure, or elevated blood sugar. Location of fat matters more than the amount — abdominal fat carries the greatest risk."
              },
              {
                question: "How often should I check my weight for overweight status?",
                answer: "Weighing yourself once per week at the same time provides the most useful trend data without causing unnecessary anxiety over daily fluctuations. Weight can vary 2-5 pounds day to day based on hydration, sodium intake, and digestive contents. Focus on the weekly or monthly trend rather than any single measurement."
              }
            ],
            related_slugs: ["bmi-for-women-calculator", "bmi-for-men-calculator", "bmi-for-seniors-calculator"],
            base_calculator_slug: "bmi-calculator",
            base_calculator_path: :health_bmi_path
          }
        ]
      }.freeze
    end
  end
end
