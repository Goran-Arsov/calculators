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
import PaycheckCalculatorController from "controllers/paycheck_calculator_controller"
import FourOhOneKCalculatorController from "controllers/four_oh_one_k_calculator_controller"
import AmortizationCalculatorController from "controllers/amortization_calculator_controller"
import StockProfitCalculatorController from "controllers/stock_profit_calculator_controller"
import CdCalculatorController from "controllers/cd_calculator_controller"
import SavingsInterestCalculatorController from "controllers/savings_interest_calculator_controller"
import HouseFlipCalculatorController from "controllers/house_flip_calculator_controller"
import StudentLoanCalculatorController from "controllers/student_loan_calculator_controller"
import EstateTaxCalculatorController from "controllers/estate_tax_calculator_controller"
import CryptoProfitCalculatorController from "controllers/crypto_profit_calculator_controller"
import SimpleInterestCalculatorController from "controllers/simple_interest_calculator_controller"

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
import MatrixCalculatorController from "controllers/matrix_calculator_controller"
import LogarithmCalculatorController from "controllers/logarithm_calculator_controller"
import ProbabilityCalculatorController from "controllers/probability_calculator_controller"
import PermutationCombinationCalculatorController from "controllers/permutation_combination_calculator_controller"
import MeanMedianModeCalculatorController from "controllers/mean_median_mode_calculator_controller"
import BaseConverterCalculatorController from "controllers/base_converter_calculator_controller"
import SigFigsCalculatorController from "controllers/sig_figs_calculator_controller"
import ScientificNotationCalculatorController from "controllers/scientific_notation_calculator_controller"

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
import ResistorColorCodeCalculatorController from "controllers/resistor_color_code_calculator_controller"
import GearRatioCalculatorController from "controllers/gear_ratio_calculator_controller"
import PressureConverterCalculatorController from "controllers/pressure_converter_calculator_controller"
import HeatTransferCalculatorController from "controllers/heat_transfer_calculator_controller"
import SpringConstantCalculatorController from "controllers/spring_constant_calculator_controller"

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
import IdealWeightCalculatorController from "controllers/ideal_weight_calculator_controller"
import BacCalculatorController from "controllers/bac_calculator_controller"
import ConceptionCalculatorController from "controllers/conception_calculator_controller"
import HeartRateZoneCalculatorController from "controllers/heart_rate_zone_calculator_controller"
import KetoCalculatorController from "controllers/keto_calculator_controller"
import IntermittentFastingCalculatorController from "controllers/intermittent_fasting_calculator_controller"
import OvulationCalculatorController from "controllers/ovulation_calculator_controller"
import BloodPressureCalculatorController from "controllers/blood_pressure_calculator_controller"
import LeanBodyMassCalculatorController from "controllers/lean_body_mass_calculator_controller"

// Construction calculators
import PaintCalculatorController from "controllers/paint_calculator_controller"
import FlooringCalculatorController from "controllers/flooring_calculator_controller"
import ConcreteCalculatorController from "controllers/concrete_calculator_controller"
import GravelMulchCalculatorController from "controllers/gravel_mulch_calculator_controller"
import FenceCalculatorController from "controllers/fence_calculator_controller"
import RoofingCalculatorController from "controllers/roofing_calculator_controller"
import StaircaseCalculatorController from "controllers/staircase_calculator_controller"
import DeckCalculatorController from "controllers/deck_calculator_controller"
import WallpaperCalculatorController from "controllers/wallpaper_calculator_controller"
import TileCalculatorController from "controllers/tile_calculator_controller"
import LumberCalculatorController from "controllers/lumber_calculator_controller"
import HvacBtuCalculatorController from "controllers/hvac_btu_calculator_controller"

// Everyday calculators
import TipCalculatorController from "controllers/tip_calculator_controller"
import DiscountCalculatorController from "controllers/discount_calculator_controller"
import AgeCalculatorController from "controllers/age_calculator_controller"
import DateDifferenceCalculatorController from "controllers/date_difference_calculator_controller"
import GasMileageCalculatorController from "controllers/gas_mileage_calculator_controller"
import FuelCostCalculatorController from "controllers/fuel_cost_calculator_controller"
import GpaCalculatorController from "controllers/gpa_calculator_controller"
import CookingConverterController from "controllers/cooking_converter_controller"
import TimeZoneConverterCalculatorController from "controllers/time_zone_converter_calculator_controller"
import ShoeSizeCalculatorController from "controllers/shoe_size_calculator_controller"
import GradeCalculatorController from "controllers/grade_calculator_controller"
import ElectricityBillCalculatorController from "controllers/electricity_bill_calculator_controller"
import MovingCostCalculatorController from "controllers/moving_cost_calculator_controller"
import PasswordStrengthCalculatorController from "controllers/password_strength_calculator_controller"
import ScreenSizeCalculatorController from "controllers/screen_size_calculator_controller"
import BandwidthCalculatorController from "controllers/bandwidth_calculator_controller"
import UnitPriceCalculatorController from "controllers/unit_price_calculator_controller"

// UI controllers
import DarkModeController from "controllers/dark_mode_controller"
import NavbarController from "controllers/navbar_controller"
import CalculatorSearchController from "controllers/calculator_search_controller"
import CookieConsentController from "controllers/cookie_consent_controller"
import AdEngagementController from "controllers/ad_engagement_controller"
import CalculatorRatingController from "controllers/calculator_rating_controller"

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
application.register("paycheck-calculator", PaycheckCalculatorController)
application.register("four-oh-one-k-calculator", FourOhOneKCalculatorController)
application.register("amortization-calculator", AmortizationCalculatorController)
application.register("stock-profit-calculator", StockProfitCalculatorController)
application.register("cd-calculator", CdCalculatorController)
application.register("savings-interest-calculator", SavingsInterestCalculatorController)
application.register("house-flip-calculator", HouseFlipCalculatorController)
application.register("student-loan-calculator", StudentLoanCalculatorController)
application.register("estate-tax-calculator", EstateTaxCalculatorController)
application.register("crypto-profit-calculator", CryptoProfitCalculatorController)
application.register("simple-interest-calculator", SimpleInterestCalculatorController)

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
application.register("matrix-calculator", MatrixCalculatorController)
application.register("logarithm-calculator", LogarithmCalculatorController)
application.register("probability-calculator", ProbabilityCalculatorController)
application.register("permutation-combination-calculator", PermutationCombinationCalculatorController)
application.register("mean-median-mode-calculator", MeanMedianModeCalculatorController)
application.register("base-converter-calculator", BaseConverterCalculatorController)
application.register("sig-figs-calculator", SigFigsCalculatorController)
application.register("scientific-notation-calculator", ScientificNotationCalculatorController)

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
application.register("resistor-color-code-calculator", ResistorColorCodeCalculatorController)
application.register("gear-ratio-calculator", GearRatioCalculatorController)
application.register("pressure-converter-calculator", PressureConverterCalculatorController)
application.register("heat-transfer-calculator", HeatTransferCalculatorController)
application.register("spring-constant-calculator", SpringConstantCalculatorController)

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
application.register("ideal-weight-calculator", IdealWeightCalculatorController)
application.register("bac-calculator", BacCalculatorController)
application.register("conception-calculator", ConceptionCalculatorController)
application.register("heart-rate-zone-calculator", HeartRateZoneCalculatorController)
application.register("keto-calculator", KetoCalculatorController)
application.register("intermittent-fasting-calculator", IntermittentFastingCalculatorController)
application.register("ovulation-calculator", OvulationCalculatorController)
application.register("blood-pressure-calculator", BloodPressureCalculatorController)
application.register("lean-body-mass-calculator", LeanBodyMassCalculatorController)

// Construction
application.register("paint-calculator", PaintCalculatorController)
application.register("flooring-calculator", FlooringCalculatorController)
application.register("concrete-calculator", ConcreteCalculatorController)
application.register("gravel-mulch-calculator", GravelMulchCalculatorController)
application.register("fence-calculator", FenceCalculatorController)
application.register("roofing-calculator", RoofingCalculatorController)
application.register("staircase-calculator", StaircaseCalculatorController)
application.register("deck-calculator", DeckCalculatorController)
application.register("wallpaper-calculator", WallpaperCalculatorController)
application.register("tile-calculator", TileCalculatorController)
application.register("lumber-calculator", LumberCalculatorController)
application.register("hvac-btu-calculator", HvacBtuCalculatorController)

// Everyday
application.register("tip-calculator", TipCalculatorController)
application.register("discount-calculator", DiscountCalculatorController)
application.register("age-calculator", AgeCalculatorController)
application.register("date-difference-calculator", DateDifferenceCalculatorController)
application.register("gas-mileage-calculator", GasMileageCalculatorController)
application.register("fuel-cost-calculator", FuelCostCalculatorController)
application.register("gpa-calculator", GpaCalculatorController)
application.register("cooking-converter", CookingConverterController)
application.register("time-zone-converter-calculator", TimeZoneConverterCalculatorController)
application.register("shoe-size-calculator", ShoeSizeCalculatorController)
application.register("grade-calculator", GradeCalculatorController)
application.register("electricity-bill-calculator", ElectricityBillCalculatorController)
application.register("moving-cost-calculator", MovingCostCalculatorController)
application.register("password-strength-calculator", PasswordStrengthCalculatorController)
application.register("screen-size-calculator", ScreenSizeCalculatorController)
application.register("bandwidth-calculator", BandwidthCalculatorController)
application.register("unit-price-calculator", UnitPriceCalculatorController)

// UI
application.register("dark-mode", DarkModeController)
application.register("navbar", NavbarController)
application.register("calculator-search", CalculatorSearchController)
application.register("cookie-consent", CookieConsentController)
application.register("ad-engagement", AdEngagementController)
application.register("calculator-rating", CalculatorRatingController)
