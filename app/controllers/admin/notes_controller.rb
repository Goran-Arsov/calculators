# frozen_string_literal: true

module Admin
  class NotesController < BaseController
    PER_PAGE = 60

    def index
      @sort = Note::SORT_OPTIONS.include?(params[:sort]) ? params[:sort] : "latest"
      @total = Note.count
      @columns = [ 1 + (@total / 50), 4 ].min
      @page = [ params[:page].to_i, 1 ].max
      @total_pages = [ (@total.to_f / PER_PAGE).ceil, 1 ].max
      @page = @total_pages if @page > @total_pages
      @notes = Note.sorted_by(@sort).limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
    end

    def new
      @note = Note.new
    end

    def create
      title = params[:note]&.dig(:title)
      body = params[:note]&.dig(:body)

      if body.blank?
        redirect_to new_admin_note_path, alert: "Please enter some text."
        return
      end

      note = NoteWriter.new(title: title, body: body).call

      if note
        redirect_to admin_notes_path, notice: "Note saved."
      else
        redirect_to new_admin_note_path, alert: "Could not save the note. Is it empty or over 1 MB?"
      end
    end

    def show
      @note = Note.find(params[:id])

      unless @note.exists_on_disk?
        head :not_found
        return
      end

      if params[:download].present?
        send_file @note.disk_path,
          type: "text/plain; charset=utf-8",
          disposition: "attachment",
          filename: "#{@note.title.presence || 'note'}.txt"
      else
        @body = @note.read_body.to_s
        set_meta_tags title: @note.title.presence || "Untitled note"
      end
    end

    def edit
      @note = Note.find(params[:id])
      @body = @note.read_body.to_s
      set_meta_tags title: "Edit: #{@note.title.presence || 'Untitled note'}"
    end

    def update
      note = Note.find(params[:id])
      title = params[:note]&.dig(:title)
      body = params[:note]&.dig(:body)

      if body.blank?
        redirect_to edit_admin_note_path(note), alert: "Please enter some text."
        return
      end

      updated = NoteWriter.new(title: title, body: body, note: note).call

      if updated
        redirect_to admin_notes_path, notice: "Note updated."
      else
        redirect_to edit_admin_note_path(note), alert: "Could not save the note. Is it empty or over 1 MB?"
      end
    end

    def destroy
      Note.find(params[:id]).destroy
      redirect_to admin_notes_path, notice: "Note deleted."
    end
  end
end
