# frozen_string_literal: true

class NavBarComponent < ViewComponent::Base
  def initialize(current_user)
    @current_user = current_user
  end

  def sulemio_tweets_path_with_duration(start_days_ago, end_days_ago)
    scope = :classified_with_sulemio_photo
    start_time = start_days_ago.days.ago.beginning_of_day.iso8601
    end_time = end_days_ago.days.ago.end_of_day.iso8601
    tweets_path(scope: scope, start_time: start_time, end_time: end_time)
  end

  def sulemio_tweets_path_by_date(start_time, end_time)
    scope = :classified_with_sulemio_photo
    tweets_path(scope: scope, start_time: start_time, end_time: end_time)
  end

  def sulemio_tweets_path_today
    sulemio_tweets_path_by_date(Time.zone.now.beginning_of_day.iso8601, Time.zone.now.end_of_day.iso8601)
  end

  def sulemio_tweets_path_yesterday
    sulemio_tweets_path_by_date(1.day.ago.beginning_of_day.iso8601, 1.day.ago.end_of_day.iso8601)
  end

  def sulemio_tweets_path_day_before_yesterday
    sulemio_tweets_path_by_date(2.days.ago.beginning_of_day.iso8601, 2.days.ago.end_of_day.iso8601)
  end

  def sulemio_tweets_path_this_week
    sulemio_tweets_path_by_date(Time.zone.now.beginning_of_week.iso8601, Time.zone.now.end_of_week.iso8601)
  end

  def sulemio_tweets_path_last_week
    sulemio_tweets_path_by_date(1.week.ago.beginning_of_week.iso8601, 1.week.ago.end_of_week.iso8601)
  end

  def sulemio_tweets_path_this_month
    sulemio_tweets_path_by_date(Time.zone.now.beginning_of_month.iso8601, Time.zone.now.end_of_month.iso8601)
  end

  def sulemio_tweets_path_last_month
    sulemio_tweets_path_by_date(1.month.ago.beginning_of_month.iso8601, 1.month.ago.end_of_month.iso8601)
  end
end
