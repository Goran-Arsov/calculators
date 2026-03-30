BlogPost.find_or_create_by!(slug: "how-to-calculate-monthly-mortgage-payment") do |post|
  post.title = "How to Calculate Your Monthly Mortgage Payment (Step by Step)"
  post.excerpt = "Learn the exact formula lenders use to calculate your monthly mortgage payment, with a step-by-step walkthrough and real examples."
  post.meta_title = "How to Calculate Monthly Mortgage Payment — Step-by-Step Guide"
  post.meta_description = "Learn the mortgage payment formula, see worked examples, and understand how interest rate and loan term affect your monthly payment."
  post.category = "finance"
  post.published_at = Time.current - 3.days
  post.body = <<~HTML
    <p>Understanding how your monthly mortgage payment is calculated can help you make smarter decisions when buying a home. In this guide, we'll break down the formula and walk through a real example.</p>

    <h2>The Mortgage Payment Formula</h2>
    <p>The standard formula for a fixed-rate mortgage payment is:</p>
    <p><strong>M = P × [r(1+r)^n] / [(1+r)^n − 1]</strong></p>
    <p>Where:</p>
    <ul>
      <li><strong>M</strong> = Monthly payment</li>
      <li><strong>P</strong> = Principal (loan amount)</li>
      <li><strong>r</strong> = Monthly interest rate (annual rate ÷ 12)</li>
      <li><strong>n</strong> = Total number of payments (years × 12)</li>
    </ul>

    <h2>Worked Example</h2>
    <p>Let's say you're borrowing $300,000 at 6.5% interest for 30 years:</p>
    <ul>
      <li>P = $300,000</li>
      <li>r = 0.065 ÷ 12 = 0.005417</li>
      <li>n = 30 × 12 = 360</li>
    </ul>
    <p>Plugging into the formula: M = $300,000 × [0.005417 × (1.005417)^360] / [(1.005417)^360 − 1] = <strong>$1,896.20 per month</strong>.</p>
    <p>Over 30 years, you'd pay a total of $682,633 — meaning $382,633 goes to interest alone. That's why even a small rate reduction matters enormously over the life of a loan.</p>

    <h2>How Interest Rate Affects Your Payment</h2>
    <p>On a $300,000 loan over 30 years, here's how different rates compare:</p>
    <ul>
      <li>5.0%: $1,610/month ($279,767 total interest)</li>
      <li>6.0%: $1,799/month ($347,515 total interest)</li>
      <li>7.0%: $1,996/month ($418,527 total interest)</li>
    </ul>
    <p>Each percentage point adds roughly $200/month and over $70,000 in total interest.</p>

    <h2>Tips to Lower Your Mortgage Payment</h2>
    <ul>
      <li><strong>Make a larger down payment</strong> to reduce the principal.</li>
      <li><strong>Shop around</strong> — even 0.25% lower can save thousands.</li>
      <li><strong>Choose a shorter term</strong> (15 years) for a lower rate, if you can afford higher payments.</li>
      <li><strong>Improve your credit score</strong> before applying to qualify for better rates.</li>
    </ul>

    <p>Try our <a href="/finance/mortgage-calculator">free mortgage calculator</a> to run your own numbers instantly.</p>
  HTML
end

BlogPost.find_or_create_by!(slug: "compound-interest-explained") do |post|
  post.title = "Compound Interest Explained: The Most Powerful Force in Finance"
  post.excerpt = "Albert Einstein reportedly called compound interest the eighth wonder of the world. Here's why it matters for your savings and investments."
  post.meta_title = "Compound Interest Explained — How It Works and Why It Matters"
  post.meta_description = "Understand compound interest with clear examples. Learn how compounding frequency, time, and rate affect your wealth over time."
  post.category = "finance"
  post.published_at = Time.current - 7.days
  post.body = <<~HTML
    <p>Compound interest is interest earned on both your original principal and on previously accumulated interest. It's the reason why starting to save early makes such a dramatic difference in your final wealth.</p>

    <h2>Simple vs. Compound Interest</h2>
    <p><strong>Simple interest</strong> is calculated only on the original principal. If you invest $10,000 at 5% simple interest, you earn $500 every year — always $500, regardless of how long you invest.</p>
    <p><strong>Compound interest</strong> includes interest on the interest. That same $10,000 at 5% compounded annually earns $500 the first year, $525 the second year, $551.25 the third year, and so on. The growth accelerates over time.</p>

    <h2>The Compound Interest Formula</h2>
    <p><strong>A = P(1 + r/n)^(nt)</strong></p>
    <ul>
      <li><strong>A</strong> = Final amount</li>
      <li><strong>P</strong> = Principal</li>
      <li><strong>r</strong> = Annual interest rate (decimal)</li>
      <li><strong>n</strong> = Compounding frequency per year</li>
      <li><strong>t</strong> = Time in years</li>
    </ul>

    <h2>The Power of Time</h2>
    <p>Consider two investors who each invest $5,000 per year at 7% return:</p>
    <ul>
      <li><strong>Investor A</strong> starts at age 25 and invests for 10 years (stops at 35): Total invested = $50,000. Value at 65 = ~$602,000.</li>
      <li><strong>Investor B</strong> starts at age 35 and invests for 30 years (until 65): Total invested = $150,000. Value at 65 = ~$505,000.</li>
    </ul>
    <p>Investor A invested <em>less money</em> but ended up with <em>more</em> — because those early dollars had more time to compound.</p>

    <h2>Compounding Frequency Matters</h2>
    <p>$10,000 at 6% for 10 years:</p>
    <ul>
      <li>Annually: $17,908</li>
      <li>Monthly: $18,194</li>
      <li>Daily: $18,221</li>
    </ul>
    <p>More frequent compounding produces slightly higher returns, though the difference shrinks as frequency increases.</p>

    <p>See the difference yourself with our <a href="/finance/compound-interest-calculator">compound interest calculator</a>.</p>
  HTML
end

BlogPost.find_or_create_by!(slug: "bmi-chart-what-your-score-means") do |post|
  post.title = "BMI Chart: What Your BMI Score Really Means"
  post.excerpt = "BMI is a quick health screening tool, but it has important limitations. Learn what your BMI score means and when to look beyond the number."
  post.meta_title = "BMI Chart — What Your BMI Score Really Means"
  post.meta_description = "Understand BMI categories, how BMI is calculated, its limitations, and when to use other health metrics alongside it."
  post.category = "health"
  post.published_at = Time.current - 10.days
  post.body = <<~HTML
    <p>Body Mass Index (BMI) is one of the most commonly used health screening tools. It's a simple calculation based on your height and weight that gives a rough estimate of body fat. But what do the numbers actually mean, and when should you look beyond BMI?</p>

    <h2>BMI Categories</h2>
    <ul>
      <li><strong>Under 18.5:</strong> Underweight</li>
      <li><strong>18.5 – 24.9:</strong> Normal weight</li>
      <li><strong>25.0 – 29.9:</strong> Overweight</li>
      <li><strong>30.0 and above:</strong> Obese</li>
    </ul>

    <h2>How BMI Is Calculated</h2>
    <p>The BMI formula is straightforward:</p>
    <ul>
      <li><strong>Metric:</strong> BMI = weight (kg) ÷ height² (m²)</li>
      <li><strong>Imperial:</strong> BMI = [weight (lbs) ÷ height² (in²)] × 703</li>
    </ul>
    <p>For example, a person who is 5'10" (70 inches) and weighs 170 lbs: BMI = (170 ÷ 4900) × 703 = 24.4 — classified as normal weight.</p>

    <h2>Limitations of BMI</h2>
    <p>BMI is a useful screening tool but has well-known blind spots:</p>
    <ul>
      <li><strong>Doesn't distinguish muscle from fat.</strong> A muscular athlete and an inactive person can have the same BMI.</li>
      <li><strong>Doesn't account for fat distribution.</strong> Abdominal fat (visceral fat) is more dangerous than fat stored elsewhere.</li>
      <li><strong>Varies by age and sex.</strong> Women naturally carry more body fat, and body composition changes with age.</li>
      <li><strong>Not accurate for all ethnicities.</strong> Health risks at the same BMI differ across populations.</li>
    </ul>

    <h2>Better Used With Other Metrics</h2>
    <p>For a more complete picture, consider combining BMI with:</p>
    <ul>
      <li><strong>Waist circumference</strong> — a waist over 40" (men) or 35" (women) signals higher risk</li>
      <li><strong>Body fat percentage</strong> — measured by calipers, DEXA scan, or our <a href="/health/body-fat-calculator">body fat calculator</a></li>
      <li><strong>Waist-to-hip ratio</strong></li>
    </ul>

    <p>Calculate your BMI instantly with our <a href="/health/bmi-calculator">free BMI calculator</a>.</p>
  HTML
end

BlogPost.find_or_create_by!(slug: "percentage-calculations-guide") do |post|
  post.title = "How to Calculate Percentages: A Complete Guide with Examples"
  post.excerpt = "Master percentage calculations — from basic 'what is X% of Y' to percentage change and reverse percentages. Clear examples included."
  post.meta_title = "How to Calculate Percentages — Complete Guide with Examples"
  post.meta_description = "Learn to calculate percentages in any context: discounts, tips, grade averages, percentage change, and more. Step-by-step examples."
  post.category = "math"
  post.published_at = Time.current - 14.days
  post.body = <<~HTML
    <p>Percentages come up everywhere — shopping discounts, tip calculations, exam grades, investment returns, statistics. Here's how to handle every common type of percentage calculation.</p>

    <h2>Type 1: What is X% of Y?</h2>
    <p>This is the most common percentage question. The formula is simple:</p>
    <p><strong>Result = Y × (X / 100)</strong></p>
    <p>Example: What is 15% of 200? → 200 × 0.15 = <strong>30</strong></p>
    <p>Use this for: tips, discounts, tax calculations, commissions.</p>

    <h2>Type 2: X is What Percent of Y?</h2>
    <p><strong>Percentage = (X / Y) × 100</strong></p>
    <p>Example: 45 is what percent of 180? → (45 / 180) × 100 = <strong>25%</strong></p>
    <p>Use this for: test scores, completion rates, proportions.</p>

    <h2>Type 3: Percentage Change</h2>
    <p><strong>Change = [(New − Old) / |Old|] × 100</strong></p>
    <p>Example: Price went from $80 to $100 → [(100 − 80) / 80] × 100 = <strong>25% increase</strong></p>
    <p>Use this for: price changes, growth rates, year-over-year comparisons.</p>

    <h2>Quick Mental Math Tricks</h2>
    <ul>
      <li><strong>10% of anything:</strong> Move the decimal one place left. 10% of 250 = 25.</li>
      <li><strong>5%:</strong> Find 10%, then halve it. 5% of 250 = 12.50.</li>
      <li><strong>15%:</strong> Find 10% + 5%. 15% of 250 = 25 + 12.50 = 37.50.</li>
      <li><strong>25%:</strong> Divide by 4. 25% of 250 = 62.50.</li>
      <li><strong>X% of Y = Y% of X.</strong> So 8% of 50 = 50% of 8 = 4. Use whichever is easier.</li>
    </ul>

    <p>Practice with our <a href="/math/percentage-calculator">percentage calculator</a> to check your work instantly.</p>
  HTML
end

puts "Seeded #{BlogPost.count} blog posts."
