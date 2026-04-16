# frozen_string_literal: true

module Automotive
  class EngineHorsepowerCalculator
    attr_reader :errors

    def initialize(torque_lb_ft: nil, rpm: nil, horsepower: nil, mode: "hp_from_torque")
      @torque_lb_ft = torque_lb_ft&.to_f
      @rpm = rpm&.to_f
      @horsepower = horsepower&.to_f
      @mode = mode.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @mode == "hp_from_torque"
        hp = (@torque_lb_ft * @rpm) / 5252.0
        {
          valid: true,
          mode: @mode,
          horsepower: hp.round(2),
          torque_lb_ft: @torque_lb_ft.round(2),
          rpm: @rpm.round(0),
          kilowatts: (hp * 0.7457).round(2),
          torque_nm: (@torque_lb_ft * 1.3558).round(2)
        }
      else # torque_from_hp
        torque = (@horsepower * 5252.0) / @rpm
        {
          valid: true,
          mode: @mode,
          horsepower: @horsepower.round(2),
          torque_lb_ft: torque.round(2),
          rpm: @rpm.round(0),
          kilowatts: (@horsepower * 0.7457).round(2),
          torque_nm: (torque * 1.3558).round(2)
        }
      end
    end

    private

    def validate!
      unless %w[hp_from_torque torque_from_hp].include?(@mode)
        @errors << "Mode must be hp_from_torque or torque_from_hp"
        return
      end

      if @mode == "hp_from_torque"
        @errors << "Torque must be positive" unless @torque_lb_ft && @torque_lb_ft > 0
        @errors << "RPM must be positive" unless @rpm && @rpm > 0
      else
        @errors << "Horsepower must be positive" unless @horsepower && @horsepower > 0
        @errors << "RPM must be positive" unless @rpm && @rpm > 0
      end
    end
  end
end
