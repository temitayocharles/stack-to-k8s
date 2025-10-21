# == Schema Information
#
# Table name: likes
#
#  id           :bigint           not null, primary key
#  user_id      :bigint           not null
#  likeable_id   :bigint           not null
#  likeable_type :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_likes_on_likeable_type_and_likeable_id  (likeable_type,likeable_id)
#  index_likes_on_user_id                        (user_id)
#  index_likes_on_user_id_and_likeable           (user_id,likeable_type,likeable_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Like < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :likeable, polymorphic: true

  # Validations
  validates :user_id, uniqueness: { scope: [:likeable_type, :likeable_id] }
  validates :user, presence: true
  validates :likeable, presence: true

  # Callbacks
  after_create :increment_likes_count
  after_destroy :decrement_likes_count

  # Scopes
  scope :for_posts, -> { where(likeable_type: 'Post') }
  scope :for_comments, -> { where(likeable_type: 'Comment') }
  scope :recent, -> { order(created_at: :desc) }

  private

  def increment_likes_count
    likeable.increment!(:likes_count) if likeable.respond_to?(:likes_count)
  end

  def decrement_likes_count
    likeable.decrement!(:likes_count) if likeable.respond_to?(:likes_count) && likeable.likes_count > 0
  end
end
