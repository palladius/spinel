module Api
  module V1
    class NotesController < ApplicationController
      # GET /api/v1/notes
      def index
        notes = current_vault.notes.active
        render json: notes.map { |n| serialize_note(n) }
      end

      # GET /api/v1/notes/query?key=tags&value=sre
      def query
        key = params[:key]
        val = params[:value]

        if key.blank? || val.blank?
          return render json: { error: "Parameters 'key' and 'value' are required" }, status: :bad_request
        end

        results = current_vault.notes.query_frontmatter(key, val)
        render json: {
          query: { key: key, value: val },
          count: results.size,
          notes: results.map { |n| serialize_note(n) }
        }
      end

      private

      def serialize_note(n)
        {
          id: n.id,
          relative_path: n.relative_path,
          encrypted_body: n.encrypted_body,
          frontmatter: n.frontmatter,
          content_hash: n.content_hash,
          version: n.version,
          updated_at: n.updated_at.iso8601
        }
      end
    end
  end
end
