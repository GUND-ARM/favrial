# README

ビルド

```sh
./docker_compose build
./docker_compose run --rm web bundle lock  # これがないとローカルツリーのGemfile.lockが更新されない
```

モデルのアノテーション

```sh
./docker_compose run --rm web bundle exec annotate --models
```

起動

```sh
./docker_compose up
```

`debugger` を使う

```sh
docker attach docker attach favrial-web-1
```

分類モデルのテスト

```sh
./docker_compose run --rm -it test_ml_model
```

## バックアップ

```sh
./rails backup:tweet:json > tweets_1970_01_01.jsonl
./rails backup:tweet:yaml > tweets_1970_01_01.yaml
```
