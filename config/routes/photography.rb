namespace :photography do
  get "depth-of-field-calculator", to: "calculators#depth_of_field", as: :depth_of_field
  get "exposure-triangle-calculator", to: "calculators#exposure_triangle", as: :exposure_triangle
  get "print-size-dpi-calculator", to: "calculators#print_size_dpi", as: :print_size_dpi
  get "video-file-size-calculator", to: "calculators#video_file_size", as: :video_file_size
  get "aspect-ratio-crop-calculator", to: "calculators#aspect_ratio_crop", as: :aspect_ratio_crop
  get "golden-hour-calculator", to: "calculators#golden_hour", as: :golden_hour
  get "timelapse-interval-calculator", to: "calculators#timelapse_interval", as: :timelapse_interval
  get "photo-storage-calculator", to: "calculators#photo_storage", as: :photo_storage
end
