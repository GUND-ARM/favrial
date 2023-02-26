ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def auth_hash
    h = {
      "provider" => "twitter2",
      "uid" => "1585913733750042624",
      "info" => {
        "name" => "🦝🍅の絵をふぁぼる",
        "email" => nil,
        "nickname" => "witchandtrophy",
        "description" => "スレミオの絵をふぁぼる/スレミオ決闘委員会（仮）/創作イタリアンカフェ地球寮/スレミオ社会構成主義/フロント探検隊/うるさいオタクです遠慮なく引用RTしてください/リコリコ関連はこっち→ @recoryco",
        "image" => "https://pbs.twimg.com/profile_images/1587357812614516737/G0LrRMe7_normal.jpg",
        "urls" => {
          "Website" => "https://t.co/e8lk5j66Ch",
          "Twitter" => "https://twitter.com/witchandtrophy"
        }
      },
      "credentials" => {
        "token" => "eENmbUxvbnk5SnlxcGhacHdZbXNYT1FidVlJTXZDaHZUSGNyaDE0dmFQZGlrOjE2Njk5ODk2MzI5NjM6MToxOmF0OjE",
        "refresh_token" => "cFJFdTctbGFOUHdGSmx4VUpUdmxnZGJWZGJPT1djZWdxbHJUT0x2RkE0eE5yOjE2Njk5OTY4MDM4NTA6MToxxxxxxxx",
        "expires_at" => 1669996833,
        "expires" => true
      }
    }.freeze
    ActiveSupport::HashWithIndifferentAccess.new(h)
  end

  def auth_hash_not_beta_user
    h = {
      "provider" => "twitter2",
      "uid" => "28524511",
      "info" => {
        "name" => "🦝🍅の絵をふぁぼらない",
        "email" => nil,
        "nickname" => "witchandtrophy_fake",
        "description" => "スレミオ共産主義",
        "image" => "https://pbs.twimg.com/profile_images/1587357812614516737/G0LrRMe7_normal.jpg",
        "urls" => {
          "Website" => "https://t.co/e8lk5j66Ch",
          "Twitter" => "https://twitter.com/witchandtrophy"
        }
      },
      "credentials" => {
        "token" => "eENmbUxvbnk5SnlxcGhacHdZbXNYT1FidVlJTXZDaHZUSGNyaDE0dmFQZGlrOjE2Njk5ODk2MzI5NjM6MToxOmF0OjE",
        "refresh_token" => "cFJFdTctbGFOUHdGSmx4VUpUdmxnZGJWZGJPT1djZWdxbHJUT0x2RkE0eE5yOjE2Njk5OTY4MDM4NTA6MToxxxxxxxx",
        "expires_at" => 1669996833,
        "expires" => true
      }
    }.freeze
    ActiveSupport::HashWithIndifferentAccess.new(h)
  end

  def access_token
    client = oauth2_client
    OAuth2::AccessToken.new(
      client,
      "bWU3S3RZRTNreHFTSHhLdEdyQjdzeWYwY2J6OW1BUWNsVlVWTWpFTjlzd3NHOjE2NzA5OTA3NTMxNjg6MToxOmF0OjE",
      refresh_token: "UVU0eVEyWTNrNWNqWGxKUFB0X2t5NUVpT2VqbHY0TXU3WXB5eHVLc1NHMEhROjE2NzA5OTA3NTMxNjg6MTowOnJ0OjE",
      expires_at: 1670997953
    )
  end

  def oauth2_client
    OAuth2::Client.new(
      ENV['TWITTER_CLIENT_ID'],
      ENV['TWITTER_CLIENT_SECRET'],
      site: 'https://api.twitter.com',
      token_url: "2/oauth2/token",
      authorize_url: "https://twitter.com/i/oauth2/authorize"
    )
  end

  def raw_reverse_chronological_response
    json_file = './test/fixtures/files/reverse_chronological.json'
    File.open(json_file).read
  end

  def reverse_chronological_response
    JSON.parse(raw_reverse_chronological_response)
  end

  def tweet_hash_with_media
    {
      "text" => "やっと婿と嫁揃った！！！、！スミ！！！！！！！　婿もうちょい買えば良かったわ\nスレミオ味ふおおおおおおおおお！！！！！\nファミマで見つけたとき、思わずクソデカ大声で、え！！？？ミオミオ！って言いそうになったけど抑えた俺偉い https://t.co/UcvAwut0Fk",
      "id" => "1600535525244698626",
      "edit_history_tweet_ids" => [
        "1600535525244698626"
      ],
      "attachments" => {
        "media_keys" => [
          "3_1600535519317745664"
        ]
      },
      "author_id" => "5678901011"
    }
  end

  def user_hashes
    [user1_hash, user2_hash]
  end

  def user1_hash
    {
      "location" => "GUND-ARM inc.",
      "description" => "スレミオの画像を集めます",
      "created_at" => "2023-02-08T18:28:25.000Z",
      "username" => "GUNDBIT01",
      "profile_image_url" => "https://pbs.twimg.com/profile_images/1623390499745959936/JitlmyQn_normal.jpg",
      "name" => "GUNDBIT 01",
      "id" => "1623388250793713664",
      "verified" => false,
      "protected" => false,
      "public_metrics" => {
        "followers_count" => 1,
        "following_count" => 91,
        "tweet_count" => 1,
        "listed_count" => 0
      }
    }.deep_symbolize_keys
  end

  def user2_hash
    {
      "location" => "GUND-ARM inc.",
      "description" => "スレミオの絵をふぁぼる/スレミオ決闘委員会（仮）/創作イタリアンカフェ地球寮/スレミオ社会構成主義/公益社団法人フロント管理者ヅラオタク協会/スレミオキャピタル（投資事業有限責任組合スレミオ1号ファンド）/うるさいオタクです遠慮なく引用RTしてください/リコリコ関連はこっち→ @recoryco",
      "created_at" => "2022-10-28T08:38:04.000Z",
      "username" => "witchandtrophy",
      "profile_image_url" => "https://pbs.twimg.com/profile_images/1587357812614516737/G0LrRMe7_normal.jpg",
      "entities" => {
        "url" => {
          "urls" => [
            {
              "start" => 0,
              "end" => 23,
              "url" => "https://t.co/e8lk5j66Ch",
              "expanded_url" => "https://scrapbox.io/SuleMio/",
              "display_url" => "scrapbox.io/SuleMio/"
            }
          ]
        },
        "description" => {
          "mentions" => [
            { "start" => 139, "end" => 148, "username" => "recoryco" }
          ]
        }
      },
      "name" => "🦝🍅の絵をふぁぼる",
      "id" => "1585913733750042624",
      "pinned_tweet_id" => "1623304195054125056",
      "verified" => false,
      "protected" => false,
      "url" => "https://t.co/e8lk5j66Ch",
      "public_metrics" => {
        "followers_count" => 166,
        "following_count" => 115,
        "tweet_count" => 9031,
        "listed_count" => 2
      }
    }.deep_symbolize_keys
  end

  def use_omniauth(h=auth_hash)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:twitter2] = h
  end

  def login
    get '/auth/twitter2/callback'
  end
end
