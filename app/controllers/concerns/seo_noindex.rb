module SeoNoindex
  extend ActiveSupport::Concern

  included do
    before_action :apply_tier_four_noindex
  end

  private

  def apply_tier_four_noindex
    return unless request.get? || request.head?
    return unless Seo::NoindexList.include?(request.path)

    set_meta_tags(noindex: true)
  end
end
