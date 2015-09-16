# Ubb

Helper for Unity batch build.

[![Gem Version](https://badge.fury.io/rb/ubb.svg)](http://badge.fury.io/rb/ubb)


## Description

Unity Editor からビルドしたりパッケージを入出力する時に使うツールです。


## Installation

Install it yourself as:

```
$ gem install ubb
```

## Usage

```
$ ubb export -o hoge.unitypackage Plugins/hoge
$ ubb import hoge.unitypackage
```

Unity のプロジェクトフォルダは、明示的に指定されなければカレントディレクトリ以下で、最初に見つかったものを自動的に選択します。
明示的に指定するには `--project PATH` オプションを使用してください。



### export

指定したフォルダ及びファイルを .unitypackage としてエクスポートします。

```
ubb export -o '出力ファイル名' 'パッケージに含むファイル名（フォルダ可＆複数指定可）'
```

### import

指定した .unitypackage をプロジェクトにインポートします。

```
ubb import 'パッケージファイル名'
```

### build

指定したプロジェクトのビルドを行います。

```
ubb build --output '出力先フォルダ' --target [ios] --config [development|release|distribution]
```

* target
  * ビルドターゲットの指定。現在は `ios` のみ。
* config
  * ビルドコンフィグの指定。







## Contributing

1. Fork it ( https://github.com/fum1h1ro/ubb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
