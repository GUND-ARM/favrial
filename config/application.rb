require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # lib/autoload をZeitwerkで読み込めるようにする
    config.eager_load_paths << Rails.root.join("lib/autoload")

    # ActiveJobのアダプタの設定
    config.active_job.queue_adapter = :sidekiq

    # 公開リリースか？
    config.public_release = false

    # ログインを許可するTwitterユーザIDの一覧
    unless config.public_release
      config.beta_user_uids = [
        "1585913733750042624",
        "1597068484034588672",
        "277453711",
        "1294974565",
        "142714687",
        "1623388250793713664"  # @gundbit01
      ]
    end

    # タイムゾーンの設定
    config.time_zone = "Tokyo"
  end
end
