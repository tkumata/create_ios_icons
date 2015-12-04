#!/bin/sh

# Init
JOB_COND="NO"

# Check version of sips command
reqv="10.4.4"
ver=`sips -h | head -1 | awk '{print $2}'`

if [ $ver != $reqv ]; then
	echo "sips version is $ver. requier $reqv."
	exit 1
fi

# Check argument
if [ $# -ne 1 ]; then
	echo "Not found argument."
	echo "Usage: /path/to/this_script image_file.png"
	echo "Image file name should not have space character."
	exit 1
else
	# Image file name
	BASE_FILE=$1
    
	if [ -f $BASE_FILE ]; then
        echo "OK. File exists."
		JOB_COND="OK"
    else
        echo "File not exists."
		exit 1
	fi
    
	# Prefix temporary file
	TMP_FILE_PREFIX="kmt_xcode_icons"
fi

# Check image size
#((0
#	`sips -g all "${BASE_FILE}" | sed -n '/pixelHeight:/s//,ih=/p;/pixelWidth:/s//,iw=/p'`
#	,s=iw>ih?iw:ih
#))
# check image format
#f=`sips -g format "$BASE_FILE" | tail -1 | awk -F" " '{printf("%s\n", $2)}'`

if [ $JOB_COND = 'OK' ]; then
    # Check width and height and image format
    a=`sips -g all "${BASE_FILE}" | sed -n '/format: /p;/pixelHeight: /p;/pixelWidth: /p' | cut -d':' -f2`
    END=0
    
    for v in $a
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
            mkdir -p $outdir

            # create parent file
            sips -Z 1024 "${BASE_FILE}" --out /tmp/${TMP_FILE_PREFIX}_1024x1024.png
            sips -Z 512 "${BASE_FILE}" --out /tmp/${TMP_FILE_PREFIX}_512x512.png
        else
            echo "Image is not PNG file.\n"
            exit 1
        fi
    else
        echo "Long side is ${s}px.\nImage resolution is not enough. So please ready 1024x1024 picture."
        exit 1
    fi

    # Icon Resolution
    resolutions="180 152 144 120 114 100 87 80 76 72 57 58 50 40 29"

    # App Icons
    for res in $resolution
    do
        if [ -e "/tmp/${TMP_FILE_PREFIX}_${res}x${res}.png" ]; then
            echo "Already exist ${TMP_FILE_PREFIX}_${res}x${res}.png."
        else
            sips -Z $res "${BASE_FILE}" --out /tmp/${TMP_FILE_PREFIX}_${res}x${res}.png
        fi
    done

    # for App Store
    cp -vf "/tmp/${TMP_FILE_PREFIX}_1024x1024.png" "${outdir}/iTunesArtwork@2x.png"
    cp -vf "/tmp/${TMP_FILE_PREFIX}_512x512.png" "${outdir}/iTunesArtwork.png"

    # App icons
    cp -vf "/tmp/${TMP_FILE_PREFIX}_144x144.png" "${outdir}/Icon-72@2x.png"
    cp -vf "/tmp/${TMP_FILE_PREFIX}_72x72.png" "${outdir}/Icon-72.png"
    cp -vf "/tmp/${TMP_FILE_PREFIX}_114x114.png" "${outdir}/Icon@2x.png"
    cp -vf "/tmp/${TMP_FILE_PREFIX}_57x57.png" "${outdir}/Icon.png"
    cp -vf "/tmp/${TMP_FILE_PREFIX}_120x120.png" "${outdir}/Icon-60@2x.png"
    cp -vf "/tmp/${TMP_FILE_PREFIX}_152x152.png" "${outdir}/Icon-76@2x.png"
    cp -vf "/tmp/${TMP_FILE_PREFIX}_76x76.png" "${outdir}/Icon-76.png"
    cp -vf "/tmp/${TMP_FILE_PREFIX}_180x180.png" "${outdir}/Icon-60@3x.png"

    cp -vf "/tmp/${TMP_FILE_PREFIX}_100x100.png" "${outdir}/Icon-Small-50@2x.png"
    cp -vf "/tmp/${TMP_FILE_PREFIX}_50x50.png" "${outdir}/Icon-Small-50.png"
    cp -vf "/tmp/${TMP_FILE_PREFIX}_58x58.png" "${outdir}/Icon-Small@2x.png"
    cp -vf "/tmp/${TMP_FILE_PREFIX}_29x29.png" "${outdir}/Icon-Small.png"
    cp -vf "/tmp/${TMP_FILE_PREFIX}_80x80.png" "${outdir}/Icon-Small-40@2x.png"
    cp -vf "/tmp/${TMP_FILE_PREFIX}_40x40.png" "${outdir}/Icon-Small-40.png"
    cp -vf "/tmp/${TMP_FILE_PREFIX}_120x120.png" "${outdir}/Icon-Small-40@3x.png"

    cp -vf "/tmp/${TMP_FILE_PREFIX}_87x87.png" "${outdir}/Icon-Small@3x.png"

    # delete cache files
    rm -v /tmp/${TMP_FILE_PREFIX}_*
fi
