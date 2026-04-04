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

// Math calculators
import PercentageCalculatorController from "controllers/percentage_calculator_controller"
import FractionCalculatorController from "controllers/fraction_calculator_controller"
import AreaCalculatorController from "controllers/area_calculator_controller"
import CircumferenceCalculatorController from "controllers/circumference_calculator_controller"
import ExponentCalculatorController from "controllers/exponent_calculator_controller"

// Physics calculators
import VelocityCalculatorController from "controllers/velocity_calculator_controller"
import ForceCalculatorController from "controllers/force_calculator_controller"
import KineticEnergyCalculatorController from "controllers/kinetic_energy_calculator_controller"
import OhmsLawCalculatorController from "controllers/ohms_law_calculator_controller"
import ProjectileMotionCalculatorController from "controllers/projectile_motion_calculator_controller"

// Health calculators
import BmiCalculatorController from "controllers/bmi_calculator_controller"
import CalorieCalculatorController from "controllers/calorie_calculator_controller"
import BodyFatCalculatorController from "controllers/body_fat_calculator_controller"

// UI controllers
import DarkModeController from "controllers/dark_mode_controller"
import NavbarController from "controllers/navbar_controller"

// Finance
application.register("mortgage-calculator", MortgageCalculatorController)
application.register("compound-interest-calculator", CompoundInterestCalculatorController)
application.register("loan-calculator", LoanCalculatorController)
application.register("investment-calculator", InvestmentCalculatorController)
application.register("retirement-calculator", RetirementCalculatorController)
application.register("debt-payoff-calculator", DebtPayoffCalculatorController)
application.register("salary-calculator", SalaryCalculatorController)
application.register("savings-goal-calculator", SavingsGoalCalculatorController)

// Math
application.register("percentage-calculator", PercentageCalculatorController)
application.register("fraction-calculator", FractionCalculatorController)
application.register("area-calculator", AreaCalculatorController)
application.register("circumference-calculator", CircumferenceCalculatorController)
application.register("exponent-calculator", ExponentCalculatorController)

// Physics
application.register("velocity-calculator", VelocityCalculatorController)
application.register("force-calculator", ForceCalculatorController)
application.register("kinetic-energy-calculator", KineticEnergyCalculatorController)
application.register("ohms-law-calculator", OhmsLawCalculatorController)
application.register("projectile-motion-calculator", ProjectileMotionCalculatorController)

// Health
application.register("bmi-calculator", BmiCalculatorController)
application.register("calorie-calculator", CalorieCalculatorController)
application.register("body-fat-calculator", BodyFatCalculatorController)

// UI
application.register("dark-mode", DarkModeController)
application.register("navbar", NavbarController)
