class Note < ApplicationRecord
  belongs_to :vault

  validates :relative_path, presence: true
  validates :content_hash, presence: true

  before_validation :generate_id, on: :create

  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :updated_since, ->(time) { where("updated_at > ?", time) if time.present? }

  def soft_delete!
    update!(deleted_at: Time.current, version: version + 1)
  end

  def self.query_frontmatter(key, val)
    # Compatible across PostgreSQL and SQLite test adapter
    active.select do |n|
      fm = n.frontmatter || {}
      next false unless fm.key?(key.to_s)
      target = fm[key.to_s]
      if target.is_a?(Array)
        target.any? { |t| t.to_s.downcase.include?(val.to_s.downcase) }
      else
        target.to_s.downcase.include?(val.to_s.downcase)
      end
    end
  end

  private

  def generate_id
    self.id ||= SecureRandom.uuid
  end
end
