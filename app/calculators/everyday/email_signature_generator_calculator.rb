# frozen_string_literal: true

module Everyday
  class EmailSignatureGeneratorCalculator
    attr_reader :errors

    TEMPLATES = %w[professional minimal modern colorful].freeze

    def initialize(full_name:, job_title: "", company: "", email: "", phone: "", website: "",
                   linkedin: "", twitter: "", template: "professional", primary_color: "#2563EB")
      @full_name = full_name.to_s.strip
      @job_title = job_title.to_s.strip
      @company = company.to_s.strip
      @email = email.to_s.strip
      @phone = phone.to_s.strip
      @website = website.to_s.strip
      @linkedin = linkedin.to_s.strip
      @twitter = twitter.to_s.strip
      @template = template.to_s.strip.downcase.presence || "professional"
      @primary_color = primary_color.to_s.strip.presence || "#2563EB"
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      html = generate_signature

      {
        valid: true,
        html: html,
        template: @template,
        full_name: @full_name
      }
    end

    private

    def validate!
      @errors << "Full name is required" if @full_name.empty?
      @errors << "Invalid template: #{@template}" unless TEMPLATES.include?(@template)
    end

    def generate_signature
      case @template
      when "professional"
        professional_template
      when "minimal"
        minimal_template
      when "modern"
        modern_template
      when "colorful"
        colorful_template
      end
    end

    def professional_template
      html = <<~HTML
        <table cellpadding="0" cellspacing="0" border="0" style="font-family: Arial, Helvetica, sans-serif; font-size: 14px; color: #333333;">
          <tr>
            <td style="padding-right: 15px; border-right: 3px solid #{@primary_color};">
              <table cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td style="font-size: 18px; font-weight: bold; color: #{@primary_color}; padding-bottom: 2px;">#{@full_name}</td>
                </tr>
      HTML

      if @job_title.present? || @company.present?
        title_parts = [@job_title, @company].reject(&:empty?).join(" | ")
        html += "            <tr><td style=\"font-size: 13px; color: #666666; padding-bottom: 8px;\">#{title_parts}</td></tr>\n"
      end

      contact_lines = build_contact_lines
      contact_lines.each do |line|
        html += "            <tr><td style=\"font-size: 12px; color: #666666; padding-bottom: 2px;\">#{line}</td></tr>\n"
      end

      social_links = build_social_links
      if social_links.present?
        html += "            <tr><td style=\"padding-top: 6px;\">#{social_links}</td></tr>\n"
      end

      html += <<~HTML
              </table>
            </td>
          </tr>
        </table>
      HTML

      html
    end

    def minimal_template
      parts = [@full_name]
      parts << @job_title if @job_title.present?
      parts << @company if @company.present?

      html = <<~HTML
        <table cellpadding="0" cellspacing="0" border="0" style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; font-size: 13px; color: #555555;">
          <tr><td style="font-weight: 600; font-size: 14px; color: #111111;">#{@full_name}</td></tr>
      HTML

      if @job_title.present? || @company.present?
        html += "  <tr><td style=\"color: #888888;\">#{[@job_title, @company].reject(&:empty?).join(', ')}</td></tr>\n"
      end

      contact_parts = []
      contact_parts << @email if @email.present?
      contact_parts << @phone if @phone.present?
      if contact_parts.any?
        html += "  <tr><td style=\"padding-top: 4px;\">#{contact_parts.join(' | ')}</td></tr>\n"
      end

      html += "</table>\n"
      html
    end

    def modern_template
      html = <<~HTML
        <table cellpadding="0" cellspacing="0" border="0" style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; font-size: 14px;">
          <tr>
            <td style="padding: 15px; background-color: #{@primary_color}; border-radius: 8px 8px 0 0;">
              <span style="font-size: 20px; font-weight: bold; color: #FFFFFF;">#{@full_name}</span>
      HTML

      if @job_title.present?
        html += "          <br><span style=\"font-size: 13px; color: #FFFFFFCC;\">#{@job_title}</span>\n"
      end
      if @company.present?
        html += "          <br><span style=\"font-size: 13px; color: #FFFFFFCC;\">#{@company}</span>\n"
      end

      html += "        </td>\n      </tr>\n"
      html += "      <tr><td style=\"padding: 12px 15px; background-color: #f8f9fa; border-radius: 0 0 8px 8px; font-size: 12px; color: #555555;\">\n"

      contact_lines = build_contact_lines_inline
      html += "        #{contact_lines.join('<br>')}\n" if contact_lines.any?

      social = build_social_links
      html += "        <br>#{social}\n" if social.present?

      html += "      </td></tr>\n    </table>\n"
      html
    end

    def colorful_template
      html = <<~HTML
        <table cellpadding="0" cellspacing="0" border="0" style="font-family: Georgia, 'Times New Roman', serif; font-size: 14px; color: #333333; border-left: 5px solid #{@primary_color}; padding-left: 15px;">
          <tr><td style="font-size: 20px; font-weight: bold; color: #{@primary_color};">#{@full_name}</td></tr>
      HTML

      if @job_title.present? || @company.present?
        html += "  <tr><td style=\"font-size: 14px; font-style: italic; color: #777777;\">#{[@job_title, @company].reject(&:empty?).join(' at ')}</td></tr>\n"
      end

      html += "  <tr><td style=\"padding-top: 8px; font-size: 12px;\">\n"

      contact_lines = build_contact_lines_inline
      html += "    #{contact_lines.join(' &bull; ')}\n" if contact_lines.any?

      html += "  </td></tr>\n"

      social = build_social_links
      if social.present?
        html += "  <tr><td style=\"padding-top: 6px;\">#{social}</td></tr>\n"
      end

      html += "</table>\n"
      html
    end

    def build_contact_lines
      lines = []
      lines << "Email: <a href=\"mailto:#{@email}\" style=\"color: #{@primary_color}; text-decoration: none;\">#{@email}</a>" if @email.present?
      lines << "Phone: #{@phone}" if @phone.present?
      lines << "Web: <a href=\"#{ensure_protocol(@website)}\" style=\"color: #{@primary_color}; text-decoration: none;\">#{@website}</a>" if @website.present?
      lines
    end

    def build_contact_lines_inline
      lines = []
      lines << @email if @email.present?
      lines << @phone if @phone.present?
      lines << @website if @website.present?
      lines
    end

    def build_social_links
      links = []
      links << "<a href=\"#{ensure_protocol(@linkedin)}\" style=\"color: #{@primary_color}; text-decoration: none; font-size: 12px;\">LinkedIn</a>" if @linkedin.present?
      links << "<a href=\"#{ensure_protocol(@twitter)}\" style=\"color: #{@primary_color}; text-decoration: none; font-size: 12px;\">Twitter</a>" if @twitter.present?
      links.join(" | ")
    end

    def ensure_protocol(url)
      return url if url.start_with?("http://", "https://")

      "https://#{url}"
    end
  end
end
