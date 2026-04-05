module ProgrammaticSeo
  module Content
    module Concrete
      DEFINITION = {
        base_key: "concrete",
        category: "construction",
        stimulus_controller: "concrete-calculator",
        form_partial: "programmatic/forms/concrete",
        icon_path: "M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4",
        expansions: [
          {
            slug: "concrete-slab-calculator",
            route_name: "programmatic_concrete_slab",
            title: "Concrete Slab Calculator - Free Estimator",
            h1: "Concrete Slab Calculator",
            meta_description: "Calculate how much concrete you need for a slab, driveway, or patio. Get cubic yards, bags needed, and estimated cost for your project.",
            intro: "Concrete slabs form the foundation for driveways, patios, garage floors, and walkways. Getting the quantity right avoids costly mid-pour supply runs and wasted material. This calculator determines the exact cubic yards of concrete needed for your slab based on length, width, and thickness, then converts to ready-mix truckloads or bag counts so you can order with confidence.",
            how_it_works: {
              heading: "How to Calculate Concrete for a Slab",
              paragraphs: [
                "Slab volume is calculated by multiplying length times width times thickness, all in the same unit. The result in cubic feet is then divided by 27 to convert to cubic yards, which is the standard ordering unit for ready-mix concrete. A typical 4-inch residential slab uses about 1.23 cubic yards per 100 square feet of surface area.",
                "Most residential slabs are 4 inches thick for patios and walkways, or 6 inches thick for driveways and garage floors that must support vehicle weight. Increasing thickness from 4 to 6 inches adds 50% more concrete but dramatically increases load-bearing capacity. Your local building code specifies minimum thickness requirements for each application.",
                "Always add 5-10% extra concrete to your calculated volume to account for uneven subgrade, form irregularities, and spillage during pouring. Running short mid-pour creates a cold joint — a structural weakness where fresh concrete meets partially cured concrete — which compromises the slab's integrity and longevity."
              ]
            },
            example: {
              heading: "Example Calculation",
              scenario: "A driveway slab measuring 20 feet long, 12 feet wide, and 6 inches (0.5 feet) thick.",
              steps: [
                "Volume = 20 x 12 x 0.5 = 120 cubic feet",
                "Convert to cubic yards: 120 / 27 = 4.44 cubic yards",
                "Add 10% waste factor: 4.44 x 1.10 = 4.89 cubic yards",
                "Order 5 cubic yards of ready-mix concrete (trucks deliver in whole or half-yard increments)"
              ]
            },
            tips: [
              "Compact and level the subgrade thoroughly before pouring. Uneven ground creates thin spots that crack under load and wastes concrete filling low areas.",
              "Use 6-inch thick slabs for any surface that will support vehicles. Four-inch slabs are only appropriate for foot traffic like patios and walkways.",
              "Place control joints every 8-12 feet in each direction to guide inevitable shrinkage cracks along planned lines rather than random patterns.",
              "Schedule your pour for mild weather. Concrete cures best between 50-75 degrees Fahrenheit. Extreme heat or freezing temperatures compromise strength development."
            ],
            faq: [
              {
                question: "How thick should a concrete slab be?",
                answer: "Standard residential slabs are 4 inches thick for patios and walkways, 6 inches for driveways and garage floors, and 8 inches or more for heavy equipment pads. Commercial and industrial slabs may require 6-12 inches depending on load requirements. Check your local building code for minimum thickness specifications for your specific project type."
              },
              {
                question: "How many bags of concrete do I need for a slab?",
                answer: "An 80-pound bag of pre-mixed concrete yields approximately 0.6 cubic feet. For a 10x10-foot slab that is 4 inches thick, you need 33.3 cubic feet, which equals about 56 bags. For projects larger than 1 cubic yard (about 45 bags), ordering ready-mix delivery is usually more economical and produces a stronger, more consistent pour."
              },
              {
                question: "What type of concrete mix should I use for a slab?",
                answer: "For most residential slabs, a standard 4,000 PSI concrete mix is appropriate. Driveways in cold climates benefit from 4,500 PSI air-entrained concrete, which resists freeze-thaw damage. Decorative patios may use specialized mixes that accept stamping or coloring. Always specify air entrainment if your slab will be exposed to freezing temperatures and deicing salts."
              },
              {
                question: "Do I need rebar or wire mesh in a concrete slab?",
                answer: "Wire mesh (6x6 W1.4/W1.4) is standard for residential slabs to control crack width. Driveways and garage floors benefit from #3 or #4 rebar on 18-24 inch centers for additional strength. Slabs on poor soil or spanning soft spots definitely need rebar reinforcement. Fiber-reinforced concrete is an alternative that eliminates the need for mesh placement."
              },
              {
                question: "How long does a concrete slab take to cure?",
                answer: "Concrete reaches about 70% of its design strength in 7 days and full strength in 28 days under normal conditions. You can walk on a slab after 24-48 hours. Light vehicle traffic can resume after 7 days. Heavy loads should wait the full 28 days. Keep the surface moist for at least 7 days after pouring to ensure proper hydration and maximum strength development."
              }
            ],
            related_slugs: ["concrete-patio-calculator", "concrete-footing-calculator", "concrete-wall-calculator"],
            base_calculator_slug: "concrete-calculator",
            base_calculator_path: :construction_concrete_path
          },
          {
            slug: "concrete-footing-calculator",
            route_name: "programmatic_concrete_footing",
            title: "Concrete Footing Calculator - Free Tool",
            h1: "Concrete Footing Calculator",
            meta_description: "Calculate concrete needed for foundation footings. Supports continuous, spread, and pier footings with cubic yard and bag estimates.",
            intro: "Foundation footings distribute structural loads from walls, columns, and posts into the soil. Under-sizing a footing risks settlement and cracking; over-sizing wastes material and excavation effort. This calculator determines the precise volume of concrete needed for continuous wall footings, spread footings, and pier footings based on your dimensions and the number of footings required.",
            how_it_works: {
              heading: "How to Calculate Concrete for Footings",
              paragraphs: [
                "Continuous footings run along the entire perimeter of a foundation wall. Their volume equals length times width times depth. For example, a footing that is 20 inches wide and 10 inches deep running 120 linear feet around a house foundation requires a straightforward rectangular volume calculation converted to cubic yards.",
                "Spread footings are square or rectangular pads beneath columns or posts. Each footing's volume is calculated individually and then multiplied by the number of identical footings. A typical deck post footing is 24 inches square and 12 inches deep. Corner and mid-span footings may have different dimensions to handle different load conditions.",
                "Pier footings are cylindrical, calculated using pi times the radius squared times depth. Common diameters are 8, 10, and 12 inches. Cylindrical forms (sonotubes) define the shape. The concrete volume for a round pier is roughly 21% less than a square footing of the same width and depth, which saves material on multi-pier projects."
              ]
            },
            example: {
              heading: "Example Calculation",
              scenario: "A house foundation requiring 150 linear feet of continuous footing, 20 inches wide and 8 inches deep.",
              steps: [
                "Convert to feet: 20 inches = 1.67 feet wide, 8 inches = 0.67 feet deep",
                "Volume = 150 x 1.67 x 0.67 = 167.8 cubic feet",
                "Convert to cubic yards: 167.8 / 27 = 6.21 cubic yards",
                "Add 10% waste: 6.21 x 1.10 = 6.84 cubic yards — order 7 cubic yards"
              ]
            },
            tips: [
              "Footings must extend below the frost line in your area. Local building codes specify the minimum depth, typically 36-48 inches in northern climates and 12-18 inches in southern regions.",
              "Over-excavated footing trenches should be filled with concrete, not backfill. Disturbed soil beneath footings can compact unevenly and cause differential settlement.",
              "Place two horizontal runs of #4 rebar in continuous footings to add tensile strength. Position rebar 3 inches from the bottom and 3 inches from the top of the footing.",
              "Pour footings and let them cure for at least 2-3 days before placing foundation walls on top. This allows the footing to gain enough strength to support the wall weight."
            ],
            faq: [
              {
                question: "How wide should a concrete footing be?",
                answer: "Footing width depends on the load it carries and the soil bearing capacity. A general rule is that footings should be twice the width of the wall they support. For a standard 8-inch foundation wall, footings are typically 16-20 inches wide. Weak soils with low bearing capacity require wider footings to spread the load over a larger area."
              },
              {
                question: "How deep do footings need to be?",
                answer: "Footing depth must extend below the local frost line to prevent heaving. In the northern United States, this ranges from 36 to 48 inches. In the south, 12 to 18 inches is common. The minimum footing thickness is typically 6 to 8 inches for residential construction. Always verify requirements with your local building department before excavating."
              },
              {
                question: "What is the difference between a footing and a foundation?",
                answer: "A footing is the widened concrete base that sits at the bottom of an excavation and distributes building loads to the soil. A foundation wall sits on top of the footing and extends up to or above ground level. Together they form the foundation system. The footing is always wider than the wall above it to spread weight across more soil area."
              },
              {
                question: "Can I pour footings and walls at the same time?",
                answer: "Monolithic pours combining footings and walls are possible for some construction methods, particularly insulated concrete forms. However, traditional construction pours footings first, allows partial curing, then builds foundation walls on top. Monolithic pours require more complex formwork and are best left to experienced contractors with crews large enough to handle the volume."
              },
              {
                question: "Do footings need rebar reinforcement?",
                answer: "Yes, most building codes require at least two continuous horizontal bars of #4 rebar in residential footings. Rebar provides tensile strength that concrete alone lacks, preventing cracks from differential settlement or soil movement. In areas with expansive clay soils or seismic activity, more extensive reinforcement including vertical dowels may be required by code."
              }
            ],
            related_slugs: ["concrete-slab-calculator", "concrete-wall-calculator", "concrete-column-calculator"],
            base_calculator_slug: "concrete-calculator",
            base_calculator_path: :construction_concrete_path
          },
          {
            slug: "concrete-wall-calculator",
            route_name: "programmatic_concrete_wall",
            title: "Concrete Wall Calculator - Free Estimator",
            h1: "Concrete Wall Calculator",
            meta_description: "Calculate concrete needed for poured walls and retaining walls. Enter wall dimensions for cubic yards, truck loads, and cost estimates.",
            intro: "Poured concrete walls serve as foundation walls, retaining walls, and barrier walls across residential and commercial construction. Accurate volume estimation prevents the costly problem of ordering too little concrete for a continuous pour and having to create an unwanted cold joint. This calculator handles rectangular walls of any dimension and accounts for the waste factor inherent in formed wall pours.",
            how_it_works: {
              heading: "How to Calculate Concrete for Walls",
              paragraphs: [
                "Wall volume equals length times height times thickness. Foundation walls are typically 8 to 12 inches thick, while retaining walls may range from 8 inches for short garden walls to 24 inches or more for tall structural walls. Converting all measurements to feet before multiplying, then dividing by 27, gives you the volume in cubic yards.",
                "For walls with varying thickness — such as retaining walls that taper from a wider base to a narrower top — use the average thickness in your calculation. Measure the base thickness and top thickness, add them together, and divide by two. This average method produces accurate volume estimates for tapered wall profiles.",
                "Formed walls have higher waste rates than slabs because concrete can bulge forms slightly and some material sticks to form surfaces. Plan for 10-15% additional concrete beyond the calculated volume. Any excess from a ready-mix delivery can be used to pour small pads, fill post holes, or create stepping stones rather than being wasted entirely."
              ]
            },
            example: {
              heading: "Example Calculation",
              scenario: "A foundation wall 80 feet long, 8 feet tall, and 10 inches (0.833 feet) thick.",
              steps: [
                "Volume = 80 x 8 x 0.833 = 533.3 cubic feet",
                "Convert to cubic yards: 533.3 / 27 = 19.75 cubic yards",
                "Add 12% waste for formed wall: 19.75 x 1.12 = 22.1 cubic yards",
                "Order 22.5 cubic yards — this requires approximately 3 ready-mix truck loads at standard 8-yard capacity"
              ]
            },
            tips: [
              "Brace wall forms at 24-inch intervals and tie opposite form panels with snap ties to prevent blowouts during the pour. Wet concrete exerts 150+ pounds per square foot of lateral pressure.",
              "Pour walls in continuous lifts of 12-18 inches and vibrate each lift to eliminate air pockets. Skipping vibration creates honeycombing — voids that weaken the wall structurally.",
              "Retaining walls over 4 feet tall typically require engineering approval. The lateral earth pressure on tall retaining walls demands specific reinforcement and drainage design.",
              "Schedule wall pours for the entire wall in one session. Cold joints from interrupted pours create water infiltration paths and structural weak points in foundation walls."
            ],
            faq: [
              {
                question: "How thick should a concrete wall be?",
                answer: "Residential foundation walls are typically 8 inches thick for single-story structures and 10-12 inches for two stories or more. Retaining walls start at 8 inches for walls under 3 feet and increase with height. Commercial foundation walls may be 12-16 inches thick. Thickness requirements depend on the wall height, soil pressure, and local building codes."
              },
              {
                question: "How much does a concrete wall cost per linear foot?",
                answer: "A poured concrete foundation wall costs approximately $30-60 per linear foot for an 8-foot-tall, 8-inch-thick wall, including forming, rebar, concrete, and labor. This works out to roughly $150-200 per cubic yard installed. Costs vary significantly by region, wall complexity, and accessibility. Retaining walls with specialized drainage and waterproofing run higher."
              },
              {
                question: "Do concrete walls need waterproofing?",
                answer: "Foundation walls below grade absolutely require waterproofing or damp-proofing. At minimum, apply a bituminous coating to the exterior surface. For basements intended as living space, use a full waterproofing membrane system with drainage board and perimeter drain tile. Above-grade walls may need only a sealer for moisture resistance depending on exposure conditions."
              },
              {
                question: "What rebar is needed in a concrete wall?",
                answer: "Standard residential foundation walls require #4 rebar placed vertically at 48-inch spacing and horizontally at 48-inch spacing, forming a grid within the wall. Retaining walls need more reinforcement, typically #5 bars at 12-24 inch spacing vertically. The structural engineer specifies exact rebar sizes, spacing, and placement for walls subject to significant lateral loads."
              },
              {
                question: "Can I pour a concrete wall in sections?",
                answer: "Pouring in sections creates cold joints that are structurally weaker and prone to water infiltration. For foundation walls, always pour the entire wall in one continuous operation. If sections are unavoidable, install keyed joints or waterstops at the planned joint locations to maintain water resistance. Retaining walls can sometimes be poured in sections with proper joint treatment."
              }
            ],
            related_slugs: ["concrete-footing-calculator", "concrete-column-calculator", "concrete-slab-calculator"],
            base_calculator_slug: "concrete-calculator",
            base_calculator_path: :construction_concrete_path
          },
          {
            slug: "concrete-column-calculator",
            route_name: "programmatic_concrete_column",
            title: "Concrete Column Calculator - Free Tool",
            h1: "Concrete Column Calculator",
            meta_description: "Calculate concrete needed for round and square columns. Get cubic yards, bag counts, and sonotube requirements for your project.",
            intro: "Concrete columns support decks, pergolas, porches, and structural beams. Whether you are pouring round columns using sonotube forms or square columns with built forms, getting the volume right for each column and multiplying by the total count gives you an accurate order quantity. This calculator handles both cylindrical and rectangular column shapes with adjustable dimensions and quantities.",
            how_it_works: {
              heading: "How to Calculate Concrete for Columns",
              paragraphs: [
                "Round columns use the cylinder volume formula: pi times the radius squared times the height. A 12-inch diameter sonotube that is 4 feet deep requires pi times 0.5 squared times 4, which equals 3.14 cubic feet per column. Multiply by the number of columns and add a waste factor for your total concrete order.",
                "Square columns use simple rectangular volume: side length times side length times height. A 12-inch square column that is 4 feet tall needs 1 times 1 times 4 equals 4 cubic feet. Square columns use approximately 27% more concrete than round columns of the same width and height, which is worth considering if material cost is a concern.",
                "For projects with multiple columns, consistency is critical. All columns supporting the same beam should be poured to the same height using a laser level or water level to establish a reference line. Pre-cut sonotubes to exact length before placement and verify plumb alignment. Calculate total volume across all columns before ordering to ensure a single continuous pour."
              ]
            },
            example: {
              heading: "Example Calculation",
              scenario: "A deck requiring 9 round columns using 10-inch diameter sonotubes, each 42 inches (3.5 feet) deep.",
              steps: [
                "Radius = 5 inches = 0.417 feet",
                "Volume per column = pi x 0.417² x 3.5 = 1.91 cubic feet",
                "Total for 9 columns: 1.91 x 9 = 17.17 cubic feet",
                "Convert with 10% waste: (17.17 x 1.10) / 27 = 0.70 cubic yards — about 16 bags of 80-lb pre-mix"
              ]
            },
            tips: [
              "Brace sonotubes at the top and bottom to prevent shifting during the pour. A column that sets out of plumb creates alignment problems for the structure above.",
              "Insert anchor bolts or post brackets into the top of each column immediately after pouring while the concrete is still workable. Drilling into cured concrete is far more difficult.",
              "For deep columns, pour in 2-foot lifts and rod or vibrate each lift before adding the next. This prevents air pockets from forming at the bottom of tall columns.",
              "Strip sonotubes after 24-48 hours to inspect the column surface. Leaving forms on indefinitely can trap moisture against the concrete and slow proper curing."
            ],
            faq: [
              {
                question: "What diameter sonotube should I use?",
                answer: "Diameter depends on the load being supported. For residential deck posts, 8-inch sonotubes suffice for single-story decks while 10-12 inch tubes are standard for two-story or heavy-load applications. Pergola and fence posts typically use 8-inch forms. Commercial columns may require 16-24 inch forms. Your structural engineer or local code specifies the minimum diameter for each application."
              },
              {
                question: "How deep should concrete columns be?",
                answer: "Column depth must reach below the frost line in your area, typically 36-48 inches in cold climates and 12-24 inches in warm regions. Building codes also specify minimum depth for structural footings. Many jurisdictions require columns to bear on undisturbed soil or a compacted gravel base. Check your local code before digging — the required depth varies significantly by location."
              },
              {
                question: "Should I put gravel at the bottom of a column hole?",
                answer: "A 4-6 inch layer of compacted gravel at the bottom of the hole provides drainage and a stable bearing surface. This is standard practice and required by many building codes. The gravel prevents water from pooling beneath the column base, which could cause frost heaving in cold climates or soil erosion in wet areas. Compact the gravel firmly before inserting the form."
              },
              {
                question: "How many bags of concrete for one column?",
                answer: "An 80-pound bag yields 0.6 cubic feet. A 10-inch diameter column that is 4 feet deep requires about 2.18 cubic feet, or approximately 4 bags. A 12-inch diameter column at the same depth needs 3.14 cubic feet, or about 6 bags. For projects with more than 8-10 columns, ready-mix delivery is usually more economical and produces more consistent results."
              },
              {
                question: "Can I use fiber-reinforced concrete for columns?",
                answer: "Fiber-reinforced concrete adds micro-fibers that improve crack resistance and impact toughness, making it suitable for columns. However, it does not replace structural rebar in load-bearing columns. Fibers help with shrinkage cracks and surface durability but do not provide the tensile strength needed for structural applications. Use fiber concrete as a supplement to, not a substitute for, steel reinforcement."
              }
            ],
            related_slugs: ["concrete-footing-calculator", "concrete-steps-calculator", "concrete-patio-calculator"],
            base_calculator_slug: "concrete-calculator",
            base_calculator_path: :construction_concrete_path
          },
          {
            slug: "concrete-steps-calculator",
            route_name: "programmatic_concrete_steps",
            title: "Concrete Steps Calculator - Free Estimator",
            h1: "Concrete Steps Calculator",
            meta_description: "Calculate how much concrete you need for stairs and steps. Enter dimensions and number of steps for accurate cubic yard estimates.",
            intro: "Concrete steps require more careful volume calculation than flat slabs because each step creates a stacked rectangular profile. The total concrete volume includes the full mass beneath the staircase plus each individual step above. This calculator handles the geometry for you — enter the overall rise, run, and width of your staircase along with the number of steps to get an accurate concrete quantity.",
            how_it_works: {
              heading: "How to Calculate Concrete for Steps",
              paragraphs: [
                "Concrete steps are essentially a solid wedge of concrete with a stepped top surface. The simplest approach calculates each step as an individual rectangular block and sums them. The bottom step is the largest, containing the full depth of concrete beneath it. Each subsequent step adds its own riser height times tread depth times the staircase width.",
                "Standard residential steps have a riser height of 7 to 7.75 inches and a tread depth of 10 to 11 inches. Building codes mandate maximum riser heights and minimum tread depths for safety. The total rise divided by the number of steps gives you the individual riser height, which must fall within code limits. If it does not, adjust the number of steps.",
                "The concrete volume for a staircase grows rapidly with the number of steps because each step includes all the concrete below it. A 3-step entry stair uses roughly 3 times less concrete than a 6-step stair of the same width. Include a 4-6 inch base slab beneath the bottom step and a landing pad at the top if the stairs connect to a door threshold."
              ]
            },
            example: {
              heading: "Example Calculation",
              scenario: "A 3-step front entry staircase, 5 feet wide, with 7-inch risers and 11-inch treads, plus a 4-inch base slab.",
              steps: [
                "Step 1 (bottom): 5 x 0.917 x (0.583 x 3 + 0.333) = 5 x 0.917 x 2.083 = 9.55 cubic feet",
                "Step 2 (middle): 5 x 0.917 x 0.583 = 2.67 cubic feet — but this volume is already in step 1's solid block",
                "Simplified total: Calculate as a solid wedge: 5 feet wide x (3 x 0.917 ft deep) x (average height) = approximately 14.7 cubic feet",
                "With 10% waste: 14.7 x 1.10 / 27 = 0.60 cubic yards — about 10 bags of 80-lb mix"
              ]
            },
            tips: [
              "Build step forms from 2x8 lumber for risers and secure them firmly with stakes and braces. Concrete pressure will distort insufficiently braced forms and create uneven steps.",
              "Slope each tread slightly forward (about 1/4 inch) to allow water drainage. Standing water on flat treads causes ice formation in winter and accelerated surface deterioration.",
              "Apply a broom finish perpendicular to the direction of travel on each tread for slip resistance. Smooth-finished steps become dangerously slippery when wet or icy.",
              "Pour all steps in a single session to avoid cold joints between steps. Start from the bottom step and work upward, finishing each tread before adding concrete for the next step."
            ],
            faq: [
              {
                question: "What are the standard dimensions for concrete steps?",
                answer: "Building codes typically require a maximum riser height of 7.75 inches and a minimum tread depth of 10 inches. The most comfortable dimensions are a 7-inch riser with an 11-inch tread. All risers in a staircase must be within 3/8 inch of each other in height. The minimum staircase width is 36 inches, though 48-60 inches is standard for front entries."
              },
              {
                question: "Do concrete steps need rebar?",
                answer: "Yes, concrete steps should include #3 or #4 rebar for structural integrity. Place horizontal bars along the length of each step and vertical bars connecting the steps to any landing or slab above and below. Rebar prevents the steps from separating from the structure and resists cracking from thermal expansion, settling, and impact loads from foot traffic."
              },
              {
                question: "How do I attach concrete steps to a foundation?",
                answer: "Drill and epoxy rebar dowels into the existing foundation wall at the planned connection point. These dowels extend into the new step concrete, creating a mechanical bond. Apply a bonding agent to the foundation surface before pouring. Without proper attachment, steps will eventually separate from the foundation due to frost heaving and settlement."
              },
              {
                question: "Can I pour concrete steps over existing steps?",
                answer: "Pouring over existing concrete steps is possible if the existing steps are structurally sound and the added thickness will not create problems with door thresholds or code-required landing heights. Clean the existing surface thoroughly, apply concrete bonding adhesive, and install a minimum 2-inch overlay. Thin overlays under 2 inches tend to delaminate and crack over time."
              },
              {
                question: "How long before I can walk on new concrete steps?",
                answer: "Wait at least 24-48 hours before light foot traffic. Avoid heavy use for 7 days. The surface may appear dry within hours, but the concrete beneath needs time to hydrate and develop strength. In cold weather, extend waiting times by 50%. Keep steps moist for the first 7 days by covering them with plastic sheeting or applying a curing compound."
              }
            ],
            related_slugs: ["concrete-slab-calculator", "concrete-patio-calculator", "concrete-column-calculator"],
            base_calculator_slug: "concrete-calculator",
            base_calculator_path: :construction_concrete_path
          },
          {
            slug: "concrete-patio-calculator",
            route_name: "programmatic_concrete_patio",
            title: "Concrete Patio Calculator - Free Estimator",
            h1: "Concrete Patio Calculator",
            meta_description: "Calculate concrete needed for your patio project. Get cubic yards, bag counts, and material estimates for standard and decorative concrete patios.",
            intro: "A concrete patio extends your living space outdoors and provides a durable, low-maintenance surface for furniture, grills, and entertaining. Whether you are planning a simple rectangular pad or a shaped patio with curves, accurate concrete estimation saves money and ensures you have enough material for a continuous pour. This calculator handles standard rectangular patios with adjustable thickness for your specific project needs.",
            how_it_works: {
              heading: "How to Calculate Concrete for a Patio",
              paragraphs: [
                "Patio concrete volume is calculated the same way as any flat slab: length times width times thickness, converted to cubic yards. Standard patio thickness is 4 inches for foot traffic only. If you plan to place heavy items like hot tubs, outdoor kitchens, or large planters, increase thickness to 5-6 inches in those areas or throughout the entire patio.",
                "Irregularly shaped patios require breaking the area into simpler geometric shapes, calculating each section separately, and adding the volumes together. A patio with a rectangular main area and a semicircular extension at one end would be calculated as the rectangle volume plus half of a circle's volume times the thickness.",
                "Decorative concrete techniques like stamping, staining, or exposed aggregate do not change the volume calculation, but they may affect the concrete mix specification. Stamped concrete typically requires a higher-slump mix for workability, and exposed aggregate uses a specific stone blend. Order the correct mix type in addition to the correct volume to avoid project delays."
              ]
            },
            example: {
              heading: "Example Calculation",
              scenario: "A rectangular backyard patio measuring 16 feet by 14 feet, 4 inches (0.333 feet) thick.",
              steps: [
                "Volume = 16 x 14 x 0.333 = 74.6 cubic feet",
                "Convert to cubic yards: 74.6 / 27 = 2.76 cubic yards",
                "Add 8% waste factor: 2.76 x 1.08 = 2.98 cubic yards",
                "Order 3 cubic yards of ready-mix concrete, or approximately 50 bags of 80-lb pre-mix for a DIY pour"
              ]
            },
            tips: [
              "Grade the patio surface to slope 1/4 inch per foot away from your house foundation. This prevents water from pooling against the building and causing basement moisture problems.",
              "Install a 4-inch compacted gravel base beneath the patio for drainage and stability. Pouring directly on clay soil risks heaving and cracking as the ground expands and contracts seasonally.",
              "Plan control joint locations before pouring. Joints should divide the patio into panels no larger than 8-10 feet square. Use a grooving tool to cut joints 1/4 of the slab depth while concrete is still workable.",
              "Consider adding a decorative border stamp or colored edge to enhance appearance at minimal additional cost. The border can be poured and stamped first as a frame before filling the center."
            ],
            faq: [
              {
                question: "How thick should a concrete patio be?",
                answer: "A standard concrete patio should be 4 inches thick for areas supporting only foot traffic and patio furniture. Increase to 5-6 inches for sections beneath hot tubs, outdoor kitchens, or fire pits. If vehicles will ever cross the patio area, use 6-inch thickness. A 4-inch patio on a proper gravel base easily handles normal residential use for decades."
              },
              {
                question: "Is a concrete patio cheaper than pavers?",
                answer: "Plain concrete is typically 30-50% less expensive than paver installation, costing $6-12 per square foot versus $10-20 for pavers. However, stamped or decorative concrete closes the gap at $12-20 per square foot. Concrete requires less maintenance but cannot be easily repaired in sections. Pavers allow individual unit replacement but may shift over time without proper edging."
              },
              {
                question: "Do I need a permit for a concrete patio?",
                answer: "Most jurisdictions require a building permit for concrete patios, especially those attached to a house or exceeding a certain size threshold, typically 200 square feet. Permits ensure the patio meets setback requirements, drainage requirements, and structural standards. Contact your local building department before starting — unpermitted work can create problems when selling your home."
              },
              {
                question: "How long does a concrete patio last?",
                answer: "A properly poured and maintained concrete patio lasts 25-50 years. Factors that shorten lifespan include poor drainage, inadequate subgrade preparation, thin pours, lack of control joints, and exposure to deicing chemicals. Sealing the surface every 2-3 years and maintaining proper drainage significantly extend the patio's functional life and appearance."
              },
              {
                question: "Can I pour a concrete patio myself?",
                answer: "A small patio under 100 square feet is manageable as a DIY project for someone with basic construction experience. Larger patios require a crew of at least 3-4 people because concrete must be placed, screeded, floated, and finished before it begins to set, typically within 1-2 hours depending on temperature. Ready-mix delivery is recommended over bagged concrete for any patio over 50 square feet."
              }
            ],
            related_slugs: ["concrete-slab-calculator", "concrete-steps-calculator", "concrete-footing-calculator"],
            base_calculator_slug: "concrete-calculator",
            base_calculator_path: :construction_concrete_path
          }
        ]
      }.freeze
    end
  end
end
