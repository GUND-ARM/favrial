namespace :backup do
  namespace :tweet do
    desc "Backup Tweets as yaml"
    task yaml: [:environment] do
      Tweet.all.to_yaml($stdout)
    end

    desc "Backup Tweets as json"
    task json: [:environment] do
      Tweet.all.each do |t|
        puts t.to_json
      end
    end
  end
end
