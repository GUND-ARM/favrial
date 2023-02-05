class TweetsController < ApplicationController
  include Pundit::Authorization

  before_action :set_tweet, only: %i[ show edit update destroy ]

  # GET /tweets or /tweets.json
  def index
    @classification = params[:classification]
    @tweets = if @classification
                Tweet.classified_with_photo(@classification).page(params[:page])
              else
                Tweet.unclassified_with_photo.page(params[:page])
              end
  end

  # GET /tweets/1 or /tweets/1.json
  def show
  end

  # GET /tweets/new
  def new
    # FIXME: ツィートの手動追加は後ほど実装する
    @tweet = Tweet.new
  end

  # GET /tweets/1/edit
  def edit
    authorize @tweet
  end

  # FIXME: ツィートの手動追加は後ほど実装する
  # POST /tweets or /tweets.json
  def create
    @tweet = Tweet.new(tweet_params)
    authorize @tweet

    respond_to do |format|
      if @tweet.save
        format.html { redirect_to tweet_url(@tweet), notice: "Tweet was successfully created." }
        format.json { render :show, status: :created, location: @tweet }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tweets/1 or /tweets/1.json
  def update
    authorize @tweet

    respond_to do |format|
      if @tweet.update(tweet_params)
        format.html { redirect_to tweet_url(@tweet), notice: "Tweet was successfully updated." }
        format.json { render :show, status: :ok, location: @tweet }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tweets/1 or /tweets/1.json
  def destroy
    # FIXME: 認可は必ず失敗するようになっている. 後ほど管理権限のあるユーザーのみ削除できるようにする
    authorize @tweet

    @tweet.destroy

    respond_to do |format|
      format.html { redirect_to tweets_url, notice: "Tweet was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # before_actionで呼び出される
  def set_tweet
    @tweet = Tweet.find(params[:id])
  end

  # 許可するパラメーターのリスト
  def tweet_params
    params.require(:tweet).permit(:classification)
  end

  # punditで認可に失敗した場合に呼び出される
  def user_not_authorized
    head :forbidden
  end
end
