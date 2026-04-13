# frozen_string_literal: true

module Admin
  class PhotosController < BaseController
    MAX_UPLOAD_BYTES = 50.megabytes
    PER_PAGE = 60

    def index
      @total = Photo.count
      @page = [ params[:page].to_i, 1 ].max
      @total_pages = [ (@total.to_f / PER_PAGE).ceil, 1 ].max
      @page = @total_pages if @page > @total_pages
      @photos = Photo.order(created_at: :desc).limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
    end

    def new
      @photo = Photo.new
    end

    def create
      uploaded = params[:photo]&.dig(:file)

      if uploaded.blank?
        redirect_to new_admin_photo_path, alert: "Please choose a file."
        return
      end

      if uploaded.size > MAX_UPLOAD_BYTES
        redirect_to new_admin_photo_path, alert: "File is too large (max 50 MB)."
        return
      end

      photo = PhotoUploader.new(uploaded).call

      if photo
        redirect_to admin_photos_path, notice: "Uploaded #{photo.original_filename}."
      else
        redirect_to new_admin_photo_path, alert: "Could not process that file. Is it a valid image?"
      end
    end

    def show
      photo = Photo.find(params[:id])

      unless photo.exists_on_disk?
        head :not_found
        return
      end

      send_file photo.disk_path,
        type: "image/jpeg",
        disposition: "inline",
        filename: photo.original_filename.presence || photo.filename
    end

    def destroy
      photo = Photo.find(params[:id])
      photo.destroy
      redirect_to admin_photos_path, notice: "Photo deleted."
    end
  end
end
