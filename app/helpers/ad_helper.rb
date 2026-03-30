module AdHelper
  def ad_slot(position)
    render "shared/ad_slot", slot: position
  end
end
