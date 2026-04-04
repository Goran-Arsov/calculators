import { application } from "controllers/application"

// Finance calculators
import MortgageCalculatorController from "controllers/mortgage_calculator_controller"
import CompoundInterestCalculatorController from "controllers/compound_interest_calculator_controller"
import LoanCalculatorController from "controllers/loan_calculator_controller"
import InvestmentCalculatorController from "controllers/investment_calculator_controller"
import RetirementCalculatorController from "controllers/retirement_calculator_controller"
import DebtPayoffCalculatorController from "controllers/debt_payoff_calculator_controller"
import SalaryCalculatorController from "controllers/salary_calculator_controller"
import SavingsGoalCalculatorController from "controllers/savings_goal_calculator_controller"
import RoiCalculatorController from "controllers/roi_calculator_controller"
import ProfitMarginCalculatorController from "controllers/profit_margin_calculator_controller"
import InflationCalculatorController from "controllers/inflation_calculator_controller"
import BreakEvenCalculatorController from "controllers/break_even_calculator_controller"
import MarkupMarginCalculatorController from "controllers/markup_margin_calculator_controller"
import RentVsBuyCalculatorController from "controllers/rent_vs_buy_calculator_controller"
import DividendYieldCalculatorController from "controllers/dividend_yield_calculator_controller"
import DcaCalculatorController from "controllers/dca_calculator_controller"
import SolarSavingsCalculatorController from "controllers/solar_savings_calculator_controller"
import TaxBracketCalculatorController from "controllers/tax_bracket_calculator_controller"
import AutoLoanCalculatorController from "controllers/auto_loan_calculator_controller"
import CreditCardPayoffCalculatorController from "controllers/credit_card_payoff_calculator_controller"
import NetWorthCalculatorController from "controllers/net_worth_calculator_controller"
import HomeAffordabilityCalculatorController from "controllers/home_affordability_calculator_controller"
import BusinessLoanCalculatorController from "controllers/business_loan_calculator_controller"
import CurrencyConverterCalculatorController from "controllers/currency_converter_calculator_controller"

// Math calculators
import PercentageCalculatorController from "controllers/percentage_calculator_controller"
import FractionCalculatorController from "controllers/fraction_calculator_controller"
import AreaCalculatorController from "controllers/area_calculator_controller"
import CircumferenceCalculatorController from "controllers/circumference_calculator_controller"
import ExponentCalculatorController from "controllers/exponent_calculator_controller"
import PythagoreanCalculatorController from "controllers/pythagorean_calculator_controller"
import QuadraticCalculatorController from "controllers/quadratic_calculator_controller"
import StandardDeviationCalculatorController from "controllers/standard_deviation_calculator_controller"
import GcdLcmCalculatorController from "controllers/gcd_lcm_calculator_controller"
import SampleSizeCalculatorController from "controllers/sample_size_calculator_controller"
import AspectRatioCalculatorController from "controllers/aspect_ratio_calculator_controller"

// Physics calculators
import VelocityCalculatorController from "controllers/velocity_calculator_controller"
import ForceCalculatorController from "controllers/force_calculator_controller"
import KineticEnergyCalculatorController from "controllers/kinetic_energy_calculator_controller"
import OhmsLawCalculatorController from "controllers/ohms_law_calculator_controller"
import ProjectileMotionCalculatorController from "controllers/projectile_motion_calculator_controller"
import ElementMassCalculatorController from "controllers/element_mass_calculator_controller"
import ElementVolumeCalculatorController from "controllers/element_volume_calculator_controller"
import UnitConverterController from "controllers/unit_converter_controller"
import ElectricityCostCalculatorController from "controllers/electricity_cost_calculator_controller"
import WireGaugeCalculatorController from "controllers/wire_gauge_calculator_controller"
import DecibelCalculatorController from "controllers/decibel_calculator_controller"
import WavelengthFrequencyCalculatorController from "controllers/wavelength_frequency_calculator_controller"
import PlanetWeightCalculatorController from "controllers/planet_weight_calculator_controller"

// Health calculators
import BmiCalculatorController from "controllers/bmi_calculator_controller"
import CalorieCalculatorController from "controllers/calorie_calculator_controller"
import BodyFatCalculatorController from "controllers/body_fat_calculator_controller"
import PregnancyDueDateCalculatorController from "controllers/pregnancy_due_date_calculator_controller"
import TdeeCalculatorController from "controllers/tdee_calculator_controller"
import MacroCalculatorController from "controllers/macro_calculator_controller"
import PaceCalculatorController from "controllers/pace_calculator_controller"
import WaterIntakeCalculatorController from "controllers/water_intake_calculator_controller"
import SleepCalculatorController from "controllers/sleep_calculator_controller"
import OneRepMaxCalculatorController from "controllers/one_rep_max_calculator_controller"
import DogAgeCalculatorController from "controllers/dog_age_calculator_controller"
import PregnancyWeekCalculatorController from "controllers/pregnancy_week_calculator_controller"
import DogFoodCalculatorController from "controllers/dog_food_calculator_controller"

// Construction calculators
import PaintCalculatorController from "controllers/paint_calculator_controller"
import FlooringCalculatorController from "controllers/flooring_calculator_controller"
import ConcreteCalculatorController from "controllers/concrete_calculator_controller"
import GravelMulchCalculatorController from "controllers/gravel_mulch_calculator_controller"
import FenceCalculatorController from "controllers/fence_calculator_controller"

// Everyday calculators
import TipCalculatorController from "controllers/tip_calculator_controller"
import DiscountCalculatorController from "controllers/discount_calculator_controller"
import AgeCalculatorController from "controllers/age_calculator_controller"
import DateDifferenceCalculatorController from "controllers/date_difference_calculator_controller"
import GasMileageCalculatorController from "controllers/gas_mileage_calculator_controller"
import FuelCostCalculatorController from "controllers/fuel_cost_calculator_controller"
import GpaCalculatorController from "controllers/gpa_calculator_controller"
import CookingConverterController from "controllers/cooking_converter_controller"

// UI controllers
import DarkModeController from "controllers/dark_mode_controller"
import NavbarController from "controllers/navbar_controller"
import CalculatorSearchController from "controllers/calculator_search_controller"
import CookieConsentController from "controllers/cookie_consent_controller"
import AdEngagementController from "controllers/ad_engagement_controller"

// Finance
application.register("mortgage-calculator", MortgageCalculatorController)
application.register("compound-interest-calculator", CompoundInterestCalculatorController)
application.register("loan-calculator", LoanCalculatorController)
application.register("investment-calculator", InvestmentCalculatorController)
application.register("retirement-calculator", RetirementCalculatorController)
application.register("debt-payoff-calculator", DebtPayoffCalculatorController)
application.register("salary-calculator", SalaryCalculatorController)
application.register("savings-goal-calculator", SavingsGoalCalculatorController)
application.register("roi-calculator", RoiCalculatorController)
application.register("profit-margin-calculator", ProfitMarginCalculatorController)
application.register("inflation-calculator", InflationCalculatorController)
application.register("break-even-calculator", BreakEvenCalculatorController)
application.register("markup-margin-calculator", MarkupMarginCalculatorController)
application.register("rent-vs-buy-calculator", RentVsBuyCalculatorController)
application.register("dividend-yield-calculator", DividendYieldCalculatorController)
application.register("dca-calculator", DcaCalculatorController)
application.register("solar-savings-calculator", SolarSavingsCalculatorController)
application.register("tax-bracket-calculator", TaxBracketCalculatorController)
application.register("auto-loan-calculator", AutoLoanCalculatorController)
application.register("credit-card-payoff-calculator", CreditCardPayoffCalculatorController)
application.register("net-worth-calculator", NetWorthCalculatorController)
application.register("home-affordability-calculator", HomeAffordabilityCalculatorController)
application.register("business-loan-calculator", BusinessLoanCalculatorController)
application.register("currency-converter-calculator", CurrencyConverterCalculatorController)

// Math
application.register("percentage-calculator", PercentageCalculatorController)
application.register("fraction-calculator", FractionCalculatorController)
application.register("area-calculator", AreaCalculatorController)
application.register("circumference-calculator", CircumferenceCalculatorController)
application.register("exponent-calculator", ExponentCalculatorController)
application.register("pythagorean-calculator", PythagoreanCalculatorController)
application.register("quadratic-calculator", QuadraticCalculatorController)
application.register("standard-deviation-calculator", StandardDeviationCalculatorController)
application.register("gcd-lcm-calculator", GcdLcmCalculatorController)
application.register("sample-size-calculator", SampleSizeCalculatorController)
application.register("aspect-ratio-calculator", AspectRatioCalculatorController)

// Physics
application.register("velocity-calculator", VelocityCalculatorController)
application.register("force-calculator", ForceCalculatorController)
application.register("kinetic-energy-calculator", KineticEnergyCalculatorController)
application.register("ohms-law-calculator", OhmsLawCalculatorController)
application.register("projectile-motion-calculator", ProjectileMotionCalculatorController)
application.register("element-mass-calculator", ElementMassCalculatorController)
application.register("element-volume-calculator", ElementVolumeCalculatorController)
application.register("unit-converter", UnitConverterController)
application.register("electricity-cost-calculator", ElectricityCostCalculatorController)
application.register("wire-gauge-calculator", WireGaugeCalculatorController)
application.register("decibel-calculator", DecibelCalculatorController)
application.register("wavelength-frequency-calculator", WavelengthFrequencyCalculatorController)
application.register("planet-weight-calculator", PlanetWeightCalculatorController)

// Health
application.register("bmi-calculator", BmiCalculatorController)
application.register("calorie-calculator", CalorieCalculatorController)
application.register("body-fat-calculator", BodyFatCalculatorController)
application.register("pregnancy-due-date-calculator", PregnancyDueDateCalculatorController)
application.register("tdee-calculator", TdeeCalculatorController)
application.register("macro-calculator", MacroCalculatorController)
application.register("pace-calculator", PaceCalculatorController)
application.register("water-intake-calculator", WaterIntakeCalculatorController)
application.register("sleep-calculator", SleepCalculatorController)
application.register("one-rep-max-calculator", OneRepMaxCalculatorController)
application.register("dog-age-calculator", DogAgeCalculatorController)
application.register("pregnancy-week-calculator", PregnancyWeekCalculatorController)
application.register("dog-food-calculator", DogFoodCalculatorController)

// Construction
application.register("paint-calculator", PaintCalculatorController)
application.register("flooring-calculator", FlooringCalculatorController)
application.register("concrete-calculator", ConcreteCalculatorController)
application.register("gravel-mulch-calculator", GravelMulchCalculatorController)
application.register("fence-calculator", FenceCalculatorController)

// Everyday
application.register("tip-calculator", TipCalculatorController)
application.register("discount-calculator", DiscountCalculatorController)
application.register("age-calculator", AgeCalculatorController)
application.register("date-difference-calculator", DateDifferenceCalculatorController)
application.register("gas-mileage-calculator", GasMileageCalculatorController)
application.register("fuel-cost-calculator", FuelCostCalculatorController)
application.register("gpa-calculator", GpaCalculatorController)
application.register("cooking-converter", CookingConverterController)

// UI
application.register("dark-mode", DarkModeController)
application.register("navbar", NavbarController)
application.register("calculator-search", CalculatorSearchController)
application.register("cookie-consent", CookieConsentController)
application.register("ad-engagement", AdEngagementController)
