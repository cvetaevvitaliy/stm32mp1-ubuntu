#!/bin/bash

DIR=$PWD
. "${DIR}/version.sh"

# Create the download directory if it doesn't exist
if [ ! -d "${DIR}/dl" ] ; then
    mkdir -p "${DIR}/dl"
fi

# Ensure ${DIR}/dl exists after attempt to create
if [ ! -d "${DIR}/dl" ] ; then
    echo "Failed to create download directory: ${DIR}/dl"
    exit 1
fi

# Download the base_rootfs_name file if it doesn't exist
if [ -f "${DIR}/dl/${base_rootfs_name}" ] ; then
    echo "File downloaded: ${DIR}/dl/${base_rootfs_name}"
else 
    wget -P "${DIR}/dl" "${link_ubuntu_relese}/${base_rootfs_name}" || { exit 1 ; }
fi

# Google Drive file details
fileid="1kEco22WrjYhaFoAfxaGbd41blzu6kYSC"
rootfs_name="ubuntu-22.04-base-stm32mp1-armhf-16-05-2022.tar.gz"
BASE_URL="https://drive.google.com/uc?export=download"

cd "${DIR}/dl"
if [ -f "${DIR}/dl/${rootfs_name}" ] ; then
    echo "File downloaded: ${DIR}/dl/${rootfs_name}"
else
    # Step 1: Fetch the download page and save cookies
    echo "Fetching initial download page..."
    wget --quiet --save-cookies cookies.txt --keep-session-cookies --no-check-certificate \
         "${BASE_URL}&id=${fileid}" -O temp.html

    # Step 2: Extract the necessary IDs from the HTML response
    CONFIRM=$(grep -oP '<input type="hidden" name="confirm" value="\K[^"]+' temp.html)
    ACTION_URL=$(grep -oP '<form id="download-form" action="\K[^"]+' temp.html)

    if [ -z "${CONFIRM}" ] || [ -z "${ACTION_URL}" ]; then
        echo "Failed to extract necessary fields. Exiting."
        rm -f temp.html cookies.txt
        cd "${DIR}"
        exit 1
    fi

    # Full URL for the file download
    FULL_DOWNLOAD_URL="${ACTION_URL}?id=${fileid}&export=download&confirm=${CONFIRM}"

    # Step 3: Use the extracted information to download the file
    echo "Downloading the file..."
    wget --quiet --load-cookies cookies.txt --no-check-certificate "${FULL_DOWNLOAD_URL}" -O "${rootfs_name}"

    # Step 4: Clean up temporary files
    echo "Cleaning up temporary files..."
    rm -f temp.html cookies.txt

    # Step 5: Validate the downloaded file
    if [ -f "${rootfs_name}" ] && [ "$(file -b --mime-type "${rootfs_name}")" != "text/html" ]; then
        echo "File successfully downloaded: ${rootfs_name}"
    else
        echo "Download failed or the file is invalid. Exiting."
        rm -f "${rootfs_name}"  # Remove invalid file
        cd "${DIR}"
        exit 1
    fi
fi

cd "${DIR}"
exit 0
