class TweetPolicy < ApplicationPolicy
  def index?
    presentable?
  end

  def show?
    presentable?
  end

  def new?
    false
  end

  def edit?
    presentable?
  end

  def create?
    #user.present?
    false
  end

  def update?
    # FIXME: ツィート自体のステータスを変更するのではなく, associationで判断などを表現したほうがいいかも
    #user.present? && (record.user == user || user.admin?)
    presentable?
  end

  def destroy?
    # FIXME: 管理者権限のあるユーザーのみ削除できるようにする
    #update?
    false
  end

  private

  def presentable?
    logged_in? && belongs_to_unprotected_user?
  end

  def belongs_to_unprotected_user?
    record.user.present? && record.user.protected == false
  end

  def logged_in?
    user.present?
  end
end
