class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :title, presence: true
  validates :rating, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than: 11}

  # if user 1 has already reviewed this product, user will see error
  validates :product, uniqueness: {scope: :user, message: "has already been reviewed by you."}
  
  after_validation :set_slug, only: [:create, :update, :show]

  def to_param
    "#{id}-#{slug}"
  end

  private

  def set_slug
    self.slug = title.to_s.parameterize
  end
  
end
