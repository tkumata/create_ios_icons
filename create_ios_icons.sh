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
    # create output directory
    OUTDIR="create_ios_icons"
    mkdir -p ${OUTDIR} 2>/dev/null

    # create parent file
    sips -Z 1024 "${BASE_FILE}" --out /tmp/${TMP_FILE_PREFIX}_1024x1024.png
    sips -Z 512 "${BASE_FILE}" --out /tmp/${TMP_FILE_PREFIX}_512x512.png
    cp -f "/tmp/${TMP_FILE_PREFIX}_1024x1024.png" "${OUTDIR}/iTunesArtwork@2x.png"
    cp -f "/tmp/${TMP_FILE_PREFIX}_512x512.png" "${OUTDIR}/iTunesArtwork.png"

    # Icon Resolution
    resolutions="180/-60@3x 152/-76@2x 144/-72@2x 120/-60@2x 114/@2x 100/-Small-50@2x 87/-Small@3x 80/-Small-40@2x 76/-76 72/-72 57/ 58/-Small@2x 50/-Small-50 40/-Small-40 29/-Small"

    # Create App icons
    for a in ${resolutions}
    do
        RES=`echo ${a} | cut -d'/' -f1`
        nameofpart=`echo ${a} | cut -d'/' -f2`
        
        if [ -e "/tmp/${TMP_FILE_PREFIX}_${RES}x${RES}.png" ]; then
            echo "Already exist ${TMP_FILE_PREFIX}_${RES}x${RES}.png."
        else
            sips -Z $RES "${BASE_FILE}" --out /tmp/${TMP_FILE_PREFIX}_${RES}x${RES}.png
            cp -f "/tmp/${TMP_FILE_PREFIX}_${RES}x${RES}.png" "${OUTDIR}/Icon${nameofpart}.png"
        fi
    done

    # Delete temporary files
    rm /tmp/${TMP_FILE_PREFIX}_*
}

# Check sips version
if [ ${VER} != ${REQVER} ]; then
	echo "sips version is ${VER}. requier ${REQVER}."
	exit 1
fi

# Check argument
if [ $# -eq 1 ]; then
	# Image file name
	BASE_FILE=$1    
    
	if [ -e ${BASE_FILE} ]; then
        echo "OK. File exists."
        
        # Input width and height and image format into $a
        IMG_INFO=`sips -g all "${BASE_FILE}" | sed -n '/format: /p;/pixelHeight: /p;/pixelWidth: /p' | cut -d':' -f2`
        END=0

        for v in $IMG_INFO
        do
            if [ $END -eq 0 ]; then
                # Get width
                iw=$v
            elif [ $END -eq 1 ]; then
                # Get height
                ih=$v
            elif [ $END -eq 2 ]; then
                # Get image format
                FORMAT=$v
            fi
            END=`expr $END + 1`
        done

        # Check length
        if [ $iw -gt $ih ]; then
            LONG=$iw
            SHORT=$ih
        elif [ $iw -lt $ih ]; then
            LONG=$ih
            SHORT=$iw
        else
            LONG=$ih
            SHORT=${LONG}
        fi

        echo "Long side: ${LONG}px"
        echo "Short side: ${SHORT}px"
        echo "Format: ${FORMAT}"
        
        if [ ${LONG} -lt 1024 ]; then
            echo "Long side is ${LONG}px.\nImage resolution is not enough. So please ready 1024px picture."
            exit 1
        else
            echo "Do you crop and duplicate this image? [y/n]"
            read CROP_ANSWER
        
            if [ ${CROP_ANSWER} = 'y' ]; then
                sips -c ${SHORT} ${SHORT} "${BASE_FILE}" --out /tmp/${TMP_FILE_PREFIX}_${BASE_FILE}
                BASE_FILE="/tmp/${TMP_FILE_PREFIX}_${BASE_FILE}"
            fi

    		create_app_icons
        fi
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
