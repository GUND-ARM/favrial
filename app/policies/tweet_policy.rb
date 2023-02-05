class TweetPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def edit?
    user.present?
  end

  def create?
    #user.present?
    false
  end

  def update?
    # FIXME: ツィート自体のステータスを変更するのではなく, associationで判断などを表現したほうがいいかも
    #user.present? && (record.user == user || user.admin?)
    user.present?
  end

  def destroy?
    # FIXME: 管理者権限のあるユーザーのみ削除できるようにする
    #update?
    false
  end
end
