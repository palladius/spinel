module Api
  module V1
    class SyncController < ApplicationController
      # POST /api/v1/sync/delta
      # Expects: { since: "2026-09-01T10:00:00Z", deltas: [ { relative_path, encrypted_body, frontmatter, content_hash, deleted } ] }
      def delta
        client_since = params[:since].present? ? Time.parse(params[:since]) : nil
        incoming_deltas = params[:deltas] || []

        applied_count = 0

        Note.transaction do
          incoming_deltas.each do |d|
            note = current_vault.notes.find_or_initialize_by(relative_path: d[:relative_path])

            if d[:deleted] == true
              if note.persisted? && note.deleted_at.nil?
                note.soft_delete!
                applied_count += 1
              end
            else
              # Only update if content hash differs or new note
              if note.new_record? || note.content_hash != d[:content_hash]
                note.encrypted_body = d[:encrypted_body]
                note.frontmatter = d[:frontmatter] || {}
                note.content_hash = d[:content_hash]
                note.deleted_at = nil
                note.version = (note.version || 0) + 1
                note.save!
                applied_count += 1
              end
            end
          end
        end

        # Gather server updates for the client since timestamp
        server_updates = current_vault.notes
        server_updates = server_updates.updated_since(client_since) if client_since

        render json: {
          synced_at: Time.current.iso8601,
          applied_count: applied_count,
          server_deltas: server_updates.map do |n|
            {
              id: n.id,
              relative_path: n.relative_path,
              encrypted_body: n.encrypted_body,
              frontmatter: n.frontmatter,
              content_hash: n.content_hash,
              version: n.version,
              deleted: n.deleted_at.present?,
              updated_at: n.updated_at.iso8601
            }
          end
        }
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end
