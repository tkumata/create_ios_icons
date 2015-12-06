# create_ios_icons.sh

## Overview

ひとつの大きい画像から、Xcode で使用する複数の小さい画像を生成するための、シェルスクリプトです。

## Description

具体的には長辺 1024 px 以上の画像を、以下のファイルへ変換し、ひとつのディレクトリに保存します。

- iTunesArtwork@2x.png
- iTunesArtwork.png
- Icon-72@2x.png
- Icon-72.png
- Icon@2x.png
- Icon.png
- Icon-60@2x.png
- Icon-76@2x.png
- Icon-76.png
- Icon-60@3x.png
- Icon-Small-50@2x.png
- Icon-Small-50.png
- Icon-Small@2x.png
- Icon-Small.png
- Icon-Small-40@2x.png
- Icon-Small-40.png
- Icon-Small-40@3x.png
- Icon-Small@3x.png

## Requirement

sips version 10.4.4

## Usage

```
$ sh create_ios_icons.sh image_file.png
```

## Plan

- 変換後のファイルを任意の場所へ保存できるようにしたい。
- 画像形式の種類を増やしたい。
- 対話形式で元画像をクロップできるようにしたい。

## License

[MIT](https://opensource.org/licenses/MIT)

## Author

[tkumata](https://github.com/tkumata)