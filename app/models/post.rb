class Post < ApplicationRecord
  validates :title, presence: true, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: true
  validates :content, presence: true
  validates :excerpt, length: { maximum: 500 }, allow_nil: true

  before_validation :generate_slug, on: :create

  scope :published, -> {
    where(is_published: true)
      .where.not(published_at: nil)
      .where("published_at <= ?", Time.current)
  }

  private

  def generate_slug
    return if slug.present?
    base = title.to_s.downcase.gsub(/[^a-z0-9\s-]/, "").gsub(/\s+/, "-").gsub(/-+/, "-").strip
    candidate = base
    counter = 1
    while Post.where(slug: candidate).exists?
      candidate = "#{base}-#{counter}"
      counter += 1
    end
    self.slug = candidate
  end
end
