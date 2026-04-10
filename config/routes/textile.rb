namespace :textile do
  get "fabric-yardage-calculator", to: "calculators#fabric_yardage", as: :fabric_yardage
  get "seam-allowance-converter", to: "calculators#seam_allowance", as: :seam_allowance
  get "knitting-gauge-calculator", to: "calculators#knitting_gauge", as: :knitting_gauge
  get "crochet-gauge-calculator", to: "calculators#crochet_gauge", as: :crochet_gauge
  get "knitting-needle-hook-size-converter", to: "calculators#needle_hook_size", as: :needle_hook_size
  get "yarn-yardage-calculator", to: "calculators#yarn_yardage", as: :yarn_yardage
  get "quilt-backing-calculator", to: "calculators#quilt_backing", as: :quilt_backing
  get "half-square-triangle-calculator", to: "calculators#half_square_triangle", as: :half_square_triangle
  get "quilt-binding-strips-calculator", to: "calculators#binding_strips", as: :binding_strips
  get "fabric-gsm-calculator", to: "calculators#fabric_gsm", as: :fabric_gsm
  get "fabric-shrinkage-calculator", to: "calculators#fabric_shrinkage", as: :fabric_shrinkage
  get "cross-stitch-fabric-calculator", to: "calculators#cross_stitch_fabric", as: :cross_stitch_fabric
end
