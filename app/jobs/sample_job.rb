class SampleJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    puts "ジョブを実行した"
  end
end
