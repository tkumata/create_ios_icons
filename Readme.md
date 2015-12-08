# create_ios_icons.sh

## Overview

ひとつの大きい画像 (png, jpg, gif, etc...) から、Xcode で使用する複数の小さい画像を生成するための、シェルスクリプトです。

## Description

具体的には長辺 1024 px 以上の画像を、以下のファイルへ変換し、ひとつのディレクトリに保存します。変換には、Mac 付属の sips(1) を用います。

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

```shell
$ sh /path/to/create_ios_icons.sh /path/to/image_file.png
```
[注意] 2byte 文字や空白があるとうまく動かない可能性があります。

実行するとこのようになります。

```shell
$ sh ../bin/create_ios_icons/create_ios_icons.sh danboard.png 
OK. File exists.

Long side: 1109px
Short side: 1030px
Format: png

Do you crop and duplicate this image? [1/2/3]
 1) Crop image by long length
 2) Crop image by short length
 3) No crop
2
/Users/xxxxx/xxxxx/danboard.png
  /private/tmp/kmt_xcode_icons_danboard.png
/private/tmp/kmt_xcode_icons_danboard.png
  /private/tmp/kmt_xcode_icons_1024x1024.png
/private/tmp/kmt_xcode_icons_danboard.png
  /private/tmp/kmt_xcode_icons_512x512.png
/private/tmp/kmt_xcode_icons_danboard.png
  /private/tmp/kmt_xcode_icons_180x180.png
/private/tmp/kmt_xcode_icons_danboard.png
  /private/tmp/kmt_xcode_icons_152x152.png
:
:
:
Complete.

$ ls create_ios_icons-151208143634
Icon-60@2x.png       Icon-72@2x.png       Icon-Small-40.png    Icon-Small-50@2x.png Icon-Small@3x.png    iTunesArtwork.png
Icon-60@3x.png       Icon-76.png          Icon-Small-40@2x.png Icon-Small.png       Icon.png             iTunesArtwork@2x.png
Icon-72.png          Icon-76@2x.png       Icon-Small-50.png    Icon-Small@2x.png    Icon@2x.png
```

## Plan

- ~~変換後のファイルを任意の場所へ保存できるようにしたい。~~ (日付ディレクトリに保存するように変更)
- ファイル名の扱いに汎用性をもたせたい。(2byte 文字とか空白とか)
- ~~画像形式の種類を増やしたい。~~ (sips 任せに変更。jpeg | tiff | png | gif | jp2 | pict | bmp | qtif | psd | sgi | tga が OK なはず。)
- ~~対話形式で元画像をクロップできるようにしたい。~~
- sips の仕様上中心からのクロップは変わらないけど、何かこう柔軟性をもたせたい。
- 綺麗なコードにしたい。

## License

Copyright (c) 2015 Tomokatsu Kumata

This software is released under the MIT License, Please see [MIT](https://opensource.org/licenses/MIT)

## Author

[tkumata](https://github.com/tkumata)