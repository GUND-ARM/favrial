class TweetsController < ApplicationController
  before_action :set_tweet, only: %i[ show edit update destroy ]
  before_action :set_current_user, only: %i[ index ]

  # GET /tweets or /tweets.json
  def index
    if @classification = params[:classification]
      @tweets = Tweet.classified_with_photo(@classification).page(params[:page])
      @count = Tweet.classified_with_photo(@classification).count
    else
      @tweets = Tweet.unclassified_with_photo.page(params[:page])
      @count = Tweet.unclassified_with_photo.count
    end
  end

  # GET /tweets/1 or /tweets/1.json
  def show
  end

  # GET /tweets/new
  def new
    @tweet = Tweet.new
  end

  # GET /tweets/1/edit
  def edit
  end

  # POST /tweets or /tweets.json
  def create
    @tweet = Tweet.new(tweet_params)

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
    @tweet.destroy

    respond_to do |format|
      format.html { redirect_to tweets_url, notice: "Tweet was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tweet
      @tweet = Tweet.find(params[:id])
    end

    def set_current_user
      if session[:user_id]
        @current_user = User.find(session[:user_id])
      else
        @current_user = nil
      end
    end

    # Only allow a list of trusted parameters through.
    def tweet_params
      #params.require(:tweet).permit(:t_id, :body, :url, :raw_json, :type, :classification, :classified)
      params.require(:tweet).permit(:classification)
    end
end
