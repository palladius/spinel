class Vault < ApplicationRecord
  has_many :notes, dependent: :destroy

  validates :name, presence: true
  validates :api_key, presence: true, uniqueness: true

  before_validation :generate_id_and_key, on: :create

  private

  def generate_id_and_key
    self.id ||= SecureRandom.uuid
    self.api_key ||= "spk_" + SecureRandom.hex(24)
  end
end
