# frozen_string_literal: true

class NavBarComponent < ViewComponent::Base
  def initialize(current_user)
    @current_user = current_user
  end

  # @param [String] year_month_string like '2020-12'
  # @return [ActiveSupport::TimeWithZone] Time object of the first day of the month
  def parse_year_month(year_month_string)
    year, month = year_month_string.split('-').map(&:to_i)
    Time.zone.local(year, month)
  end

  def tweets_path_by_scope_and_date(scope, start_date, end_date)
    start_time_string = start_date.beginning_of_day.iso8601
    end_time_string = end_date.end_of_day.iso8601
    tweets_path(scope: scope, start_time: start_time_string, end_time: end_time_string)
  end

  def tweets_path_by_scope_and_year_month(scope, year_month_string)
    start_date = parse_year_month(year_month_string).beginning_of_month
    end_date = parse_year_month(year_month_string).end_of_month
    tweets_path_by_scope_and_date(scope, start_date, end_date)
  end

  def pre_sulemio_tweets_path_by_year_month(year_month_string)
    tweets_path_by_scope_and_year_month(:pre_classified_with_sulemio_photo, year_month_string)
  end

  def sulemio_tweets_path_by_year_month(year_month_string)
    tweets_path_by_scope_and_year_month(:classified_with_sulemio_photo, year_month_string)
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
