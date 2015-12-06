#!/bin/sh

# Init
JOB_COND="NO"

# Check version of sips command
reqv="10.4.4"
ver=`sips -h | head -1 | awk '{print $2}'`

# sips version check
if [ $ver != $reqv ]; then
	echo "sips version is $ver. requier $reqv."
	exit 1
fi

# Check argument
if [ $# -ne 1 ]; then
    echo "Argument error."
    echo "Usage: sh /path/to/this_script image_file.png"
    echo "Please do not use space for file name."
    exit 1
else
	# Image file name
	BASE_FILE=$1
    
	if [ -e $BASE_FILE ]; then
        echo "OK. File exists."
		JOB_COND="OK"
    else
        echo "File not exists."
		exit 1
	fi
    
	# Prefix temporary file
	TMP_FILE_PREFIX="kmt_xcode_icons"
fi

if [ $JOB_COND = 'OK' ]; then
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
            cp -vf "/tmp/${TMP_FILE_PREFIX}_1024x1024.png" "${outdir}/iTunesArtwork@2x.png"
            cp -vf "/tmp/${TMP_FILE_PREFIX}_512x512.png" "${outdir}/iTunesArtwork.png"
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
            cp -vf "/tmp/${TMP_FILE_PREFIX}_${res}x${res}.png" "${outdir}/Icon${nameofpart}.png"
        fi
    done

    # Delete temporary files
    rm -v /tmp/${TMP_FILE_PREFIX}_*
fi
