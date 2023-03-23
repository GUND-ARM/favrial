class TweetsController < ApplicationController
  include Pundit::Authorization

  before_action :set_tweet, only: %i[ show edit update destroy ]

  # GET /tweets or /tweets.json
  def index
    redirect_to welcome_url unless current_user

    # スコープ(デフォルトはAI仮判断済みのスレミオ画像)
    @scope = params[:scope] || "pre_classified_with_sulemio_photo"
    # 判断モード(デフォルトはスレミオ)
    @dmode = params[:dmode] || "sulemio"
    @start_time = params[:start_time]
    @end_time = params[:end_time]
    @tweets = case @scope
              when "with_photo"
                # 画像つきの全てのツィートを表示する
                Tweet.with_photo.order(created_at: :desc).page(params[:page])
              when "classified_with_sulemio_photo"
                # ユーザによるスレミオ判定済みの画像を表示する
                Tweet.classified_with_sulemio_photo
                     .by_date(@start_time, @end_time)
                     .order(original_created_at: :desc)
                     .page(params[:page])
              when "pre_classified_with_sulemio_photo"
                # AI仮判断済みのスレミオ画像を表示する
                Tweet.pre_classified_with_sulemio_photo.order(created_at: :desc).page(params[:page])
              when "pre_classified_with_notsulemio_photo"
                # AI仮判断済みのスレミオ以外の画像を表示する
                Tweet.pre_classified_with_notsulemio_photo.order(created_at: :desc).page(params[:page])
              else
                # リクエストエラー
                raise ActionController::BadRequest
              end
  end

  # GET /tweets/1 or /tweets/1.json
  def show
    authorize @tweet
  end

  # GET /tweets/new
  def new
    # FIXME: ツィートの手動追加は後ほど実装する
    @tweet = Tweet.new
    authorize @tweet
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

    # FIXME: SULEMIO以外の判断もやろうとするとこれだとまずい
    classify_result = @tweet.classify_results.find_or_initialize_by(
      user: current_user,
      classification: ClassifyResult::Classification::SULEMIO
    )
    classify_result.result = tweet_params[:a_classification] == ClassifyResult::Classification::SULEMIO
    # FIXME: ここでsave!してるのは怪しすぎる
    classify_result.save!

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
    @tweet.a_classification = @tweet.classify_results.find_by(user: current_user, result: true)&.classification
  end

  # 許可するパラメーターのリスト
  def tweet_params
    params.require(:tweet).permit(:a_classification)
  end
end
