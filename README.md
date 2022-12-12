# README

ビルド

```sh
./docker_compose build
```

Gemfile.lock の更新

```sh
./docker_compose run --rm web bundle install
```

起動

```sh
./docker_compose up
```

## バックアップ

```sh
./rails backup:tweet:json > tweets_1970_01_01.jsonl
./rails backup:tweet:yaml > tweets_1970_01_01.yaml
```
