#!/bin/sh
#
# The MIT License (MIT)
#
# Copyright (c) 2015 Tomokatsu Kumata.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

# Init vars
REQVER="10.4.4"
VER=`sips -h | head -1 | awk '{print $2}'`
TMP_FILE_PREFIX="kmt_xcode_icons" # Prefix temporary file

create_app_icons()
{
    # Input width and height and image format into $a
    imginfo=`sips -g all "${BASE_FILE}" | sed -n '/format: /p;/pixelHeight: /p;/pixelWidth: /p' | cut -d':' -f2`
    END=0
    
    for v in $imginfo
    do
        if [ $END -eq 0 ]; then
            iw=$v
        elif [ $END -eq 1 ]; then
            ih=$v
        elif [ $END -eq 2 ]; then
            f=$v
        fi
        END=`expr $END + 1`
    done

    # Check long side
    if [ $iw -gt $ih ]; then
        s=$iw
    else
        s=$ih
    fi

    echo "Long side: $s"
    echo "Format: $f"
    
    if [ $s -gt 1023 ]; then
        if [ $f = "png" ]; then
            # create output directory
            outdir="create_ios_icons"
            mkdir -p ${outdir} 2>/dev/null

            # create parent file
            sips -Z 1024 "${BASE_FILE}" --out /tmp/${TMP_FILE_PREFIX}_1024x1024.png
            sips -Z 512 "${BASE_FILE}" --out /tmp/${TMP_FILE_PREFIX}_512x512.png
            cp -f "/tmp/${TMP_FILE_PREFIX}_1024x1024.png" "${outdir}/iTunesArtwork@2x.png"
            cp -f "/tmp/${TMP_FILE_PREFIX}_512x512.png" "${outdir}/iTunesArtwork.png"
        else
            echo "Image is not PNG file.\n"
            exit 1
        fi
    else
        echo "Long side is ${s}px.\nImage resolution is not enough. So please ready 1024px picture."
        exit 1
    fi

    # Icon Resolution
    resolutions="180/-60@3x 152/-76@2x 144/-72@2x 120/-60@2x 114/@2x 100/-Small-50@2x 87/-Small@3x 80/-Small-40@2x 76/-76 72/-72 57/ 58/-Small@2x 50/-Small-50 40/-Small-40 29/-Small"

    # Create App icons
    for a in ${resolutions}
    do
        res=`echo ${a} | cut -d'/' -f1`
        nameofpart=`echo ${a} | cut -d'/' -f2`
        
        if [ -e "/tmp/${TMP_FILE_PREFIX}_${res}x${res}.png" ]; then
            echo "Already exist ${TMP_FILE_PREFIX}_${res}x${res}.png."
        else
            sips -Z $res "${BASE_FILE}" --out /tmp/${TMP_FILE_PREFIX}_${res}x${res}.png
            cp -f "/tmp/${TMP_FILE_PREFIX}_${res}x${res}.png" "${outdir}/Icon${nameofpart}.png"
        fi
    done

    # Delete temporary files
    rm /tmp/${TMP_FILE_PREFIX}_*
}

# Check sips version
if [ ${VER} != ${REQVER} ]; then
	echo "sips version is ${ver}. requier ${REQVER}."
	exit 1
fi

# Check argument
if [ $# -eq 1 ]; then
	# Image file name
	BASE_FILE=$1
    
	if [ -e ${BASE_FILE} ]; then
        echo "OK. File exists."
		create_app_icons
    else
        echo "File not exists."
		exit 1
	fi
else
    echo "Argument error."
    echo "Usage: sh /path/to/this_script image_file.png"
    echo "Please do not use space for file name."
    exit 1
fi
