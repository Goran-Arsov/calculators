# frozen_string_literal: true

module Education
  class ClassScheduleBuilderCalculator
    attr_reader :errors

    VALID_DAYS = %w[monday tuesday wednesday thursday friday saturday sunday].freeze

    def initialize(classes:)
      @classes = parse_classes(classes)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      conflicts = detect_conflicts
      gaps = detect_gaps
      daily_summaries = build_daily_summaries
      total_hours = @classes.sum { |c| class_duration_hours(c) }
      total_credits = @classes.sum { |c| c[:credits] }
      earliest_start = @classes.min_by { |c| c[:start_minutes] }[:start_minutes]
      latest_end = @classes.max_by { |c| c[:end_minutes] }[:end_minutes]

      {
        valid: true,
        total_classes: @classes.size,
        total_credits: total_credits,
        total_hours_per_week: total_hours.round(2),
        conflicts: conflicts,
        has_conflicts: conflicts.any?,
        gaps: gaps,
        daily_summaries: daily_summaries,
        earliest_start: format_time(earliest_start),
        latest_end: format_time(latest_end)
      }
    end

    private

    def parse_classes(classes)
      return [] unless classes.is_a?(Array)

      classes.map do |c|
        {
          name: c[:name].to_s.strip,
          day: c[:day].to_s.downcase.strip,
          start_minutes: parse_time_to_minutes(c[:start_time]),
          end_minutes: parse_time_to_minutes(c[:end_time]),
          credits: c[:credits].to_i,
          location: c[:location].to_s.strip
        }
      end
    end

    def parse_time_to_minutes(time_str)
      return 0 unless time_str

      parts = time_str.to_s.split(":")
      hours = parts[0].to_i
      minutes = parts[1].to_i
      hours * 60 + minutes
    end

    def format_time(total_minutes)
      hours = total_minutes / 60
      minutes = total_minutes % 60
      format("%<hours>02d:%<minutes>02d", hours: hours, minutes: minutes)
    end

    def class_duration_hours(klass)
      (klass[:end_minutes] - klass[:start_minutes]) / 60.0
    end

    def validate!
      @errors << "At least one class is required" if @classes.empty?
      @classes.each_with_index do |c, i|
        @errors << "Class #{i + 1}: name is required" if c[:name].empty?
        @errors << "Class #{i + 1}: invalid day '#{c[:day]}'" unless VALID_DAYS.include?(c[:day])
        @errors << "Class #{i + 1}: end time must be after start time" unless c[:end_minutes] > c[:start_minutes]
        @errors << "Class #{i + 1}: credits must be positive" unless c[:credits] > 0
      end
    end

    def detect_conflicts
      conflicts = []

      classes_by_day = @classes.group_by { |c| c[:day] }

      classes_by_day.each do |day, day_classes|
        sorted = day_classes.sort_by { |c| c[:start_minutes] }

        sorted.each_cons(2) do |a, b|
          if a[:end_minutes] > b[:start_minutes]
            overlap_minutes = a[:end_minutes] - b[:start_minutes]
            conflicts << {
              day: day.capitalize,
              class_a: a[:name],
              class_b: b[:name],
              overlap_minutes: overlap_minutes,
              detail: "#{a[:name]} (ends #{format_time(a[:end_minutes])}) overlaps with #{b[:name]} (starts #{format_time(b[:start_minutes])}) by #{overlap_minutes} minutes"
            }
          end
        end
      end

      conflicts
    end

    def detect_gaps
      gaps = []

      classes_by_day = @classes.group_by { |c| c[:day] }

      classes_by_day.each do |day, day_classes|
        sorted = day_classes.sort_by { |c| c[:start_minutes] }

        sorted.each_cons(2) do |a, b|
          gap_minutes = b[:start_minutes] - a[:end_minutes]
          if gap_minutes > 0
            gaps << {
              day: day.capitalize,
              after_class: a[:name],
              before_class: b[:name],
              gap_minutes: gap_minutes,
              detail: "#{gap_minutes} min gap between #{a[:name]} and #{b[:name]} on #{day.capitalize}"
            }
          end
        end
      end

      gaps
    end

    def build_daily_summaries
      summaries = {}

      classes_by_day = @classes.group_by { |c| c[:day] }

      VALID_DAYS.each do |day|
        day_classes = classes_by_day[day] || []
        next if day_classes.empty?

        sorted = day_classes.sort_by { |c| c[:start_minutes] }
        total_hours = day_classes.sum { |c| class_duration_hours(c) }

        summaries[day.capitalize] = {
          classes: sorted.map { |c| { name: c[:name], time: "#{format_time(c[:start_minutes])}-#{format_time(c[:end_minutes])}", location: c[:location] } },
          total_hours: total_hours.round(2),
          class_count: day_classes.size
        }
      end

      summaries
    end
  end
end
