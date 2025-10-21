# == Schema Information
#
# Table name: follows
#
#  id          :bigint           not null, primary key
#  follower_id :bigint           not null
#  followed_id :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_follows_on_followed_id                    (followed_id)
#  index_follows_on_follower_id                    (follower_id)
#  index_follows_on_follower_id_and_followed_id    (follower_id,followed_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (followed_id => users.id)
#  fk_rails_...  (follower_id => users.id)
#

class Follow < ApplicationRecord
  # Associations
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'

  # Validations
  validates :follower_id, uniqueness: { scope: :followed_id }
  validates :follower, presence: true
  validates :followed, presence: true
  validate :cannot_follow_self

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  private

  def cannot_follow_self
    return unless follower_id && followed_id
    
    errors.add(:follower, "can't follow themselves") if follower_id == followed_id
  end
end
