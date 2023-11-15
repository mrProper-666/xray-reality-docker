#!/bin/sh

# Set ARG
PLATFORM=$1
if [ -z "$PLATFORM" ]; then
    ARCH="64"
else
    case "$PLATFORM" in
        linux/386)
            ARCH="32"
            ;;
        linux/amd64)
            ARCH="64"
            ;;
        linux/arm/v6)
            ARCH="arm32-v6"
            ;;
        linux/arm/v7)
            ARCH="arm32-v7a"
            ;;
        linux/arm64|linux/arm64/v8)
            ARCH="arm64-v8a"
            ;;
        *)
            ARCH=""
            ;;
    esac
fi
[ -z "${ARCH}" ] && echo "Error: Not supported OS Architecture" && exit 1

# Download files
XRAY_FILE="Xray-linux-${ARCH}.zip"
DGST_FILE="Xray-linux-${ARCH}.zip.dgst"
OWNER="XTLS"
REPO_NAME="Xray-core"
GH_API="https://api.github.com"
GH_REPO="$GH_API/repos/$OWNER/$REPO_NAME"
GH_LATEST="$GH_REPO/releases/latest"
response=$(wget -qO- $GH_LATEST)
XRAY_FILE_URL=`echo "$response" | jq --arg XRAY_FILE "$XRAY_FILE" '.assets[] | select(.name==$XRAY_FILE) | .browser_download_url' |  tr -d '"'`
DGST_FILE_URL=`echo "$response" | jq --arg DGST_FILE "$DGST_FILE" '.assets[] | select(.name==$DGST_FILE) | .browser_download_url' |  tr -d '"'`

echo "Downloading binary file: ${XRAY_FILE} $XRAY_FILE_URL"
echo "Downloading binary file: ${DGST_FILE} $DGST_FILE_URL"

wget -O ${PWD}/xray.zip $XRAY_FILE_URL > /dev/null 2>&1
wget -O ${PWD}/xray.zip.dgst $DGST_FILE_URL > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Error: Failed to download binary file: ${XRAY_FILE} ${DGST_FILE}" && exit 1
fi
echo "Download binary file: ${XRAY_FILE} ${DGST_FILE} completed"

# Check SHA512
XRAY_ZIP_HASH=$(sha512sum xray.zip | cut -f1 -d' ')
XRAY_ZIP_DGST_HASH=$(cat xray.zip.dgst | grep -e 'SHA512' -e 'SHA2-512' | head -n1 | cut -f2 -d' ')

if [ "${XRAY_ZIP_HASH}" = "${XRAY_ZIP_DGST_HASH}" ]; then
    echo " Check passed" && rm -fv xray.zip.dgst
else
    echo "V2RAY_ZIP_HASH: ${XRAY_ZIP_HASH}"
    echo "V2RAY_ZIP_DGST_HASH: ${XRAY_ZIP_DGST_HASH}"
    echo " Check have not passed yet " && exit 1
fi

# Prepare
echo "Prepare to use"
unzip xray.zip && chmod +x xray
mv xray /usr/bin/
mv geosite.dat geoip.dat /usr/local/share/xray/
mv config.json /etc/xray/config.json

# Clean
rm -rf ${PWD}/*
echo "Done"