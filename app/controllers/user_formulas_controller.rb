class UserFormulasController < ApplicationController
  rate_limit to: 5, within: 1.hour, only: :create, with: -> { redirect_to new_user_formula_path, alert: "Too many submissions. Please try again later." }

  def new
    @formula = UserFormula.new
    set_meta_tags(
      title: "Submit a Custom Calculator",
      description: "Submit your own calculator formula to CalcWise. Create custom calculators for finance, math, health, and more."
    )
  end

  def create
    # Honeypot spam check
    if params[:website].present?
      redirect_to new_user_formula_path, notice: "Your calculator has been submitted for review!"
      return
    end

    @formula = UserFormula.new(formula_params)
    @formula.status = "pending"

    if @formula.save
      redirect_to thank_you_user_formulas_path, notice: "Your calculator has been submitted for review!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def thank_you
    set_meta_tags(title: "Submission Received")
  end

  private

  def formula_params
    params.require(:user_formula).permit(:title, :description, :category, :author_name, :author_email, :formula_json)
  end
end
