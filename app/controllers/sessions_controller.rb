class SessionsController < ApplicationController
  def create
    @user = User.find_or_create_from_auth_hash(auth_hash)
    if allowed_user?(@user)
      session[:user_id] = @user.id
      redirect_to root_path
    else
      redirect_to root_path, status: :unauthorized, notice: "このアカウントではログインできません（現在βテスト参加者のみログインできます。βテストに参加希望される方は、@witchandtrophy までご連絡ください）"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  def auth_hash
    request.env["omniauth.auth"]
  end

  private

  def allowed_user?(user)
    if Rails.application.config.public_release
      return true
    end

    return Rails.application.config.beta_user_uids.include?(user.uid)
  end
end
