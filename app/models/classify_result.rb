class ClassifyResult < ApplicationRecord
  module Classification
    [
      :SULETTA,  # スレッタが主題のツィート
      :MIORINE,  # ミオリネが主題のツィート
      :SULEMIO,  # スレミオが主題のツィート
      :GWITCH,   # その他水星の魔女関連のツィート
      :OTHER     # それ以外のツィート
    ].each do |k|
      const_set(k, k.to_s.downcase.freeze)
    end

    def self.constants_hash
      constants.map do |k|
        [k, const_get(k)]
      end.to_h
    end
  end

  belongs_to :tweet
  belongs_to :user, optional: true

  validates :classification, inclusion: { in: Classification.constants_hash.values }
  validates :result, inclusion: { in: [true, false] }
  validates :by_ml, inclusion: { in: [true, false] }
  # 1ユーザーが1ツィートについて1つの分類しか持てない
  validates :user_id, uniqueness: { scope: [:tweet_id, :classification] }
  validates :tweet_id, uniqueness: { scope: [:user_id, :classification] }
  validates :classification, uniqueness: { scope: [:user_id, :tweet_id] }

  before_validation :set_by_ml

  private

  def set_by_ml
    self.by_ml = false if user.present?
  end
end
