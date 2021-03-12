#!/bin/bash
date=`date +%Y%m%d`
dateFormatted=`date -R`
s3Bucket="operator-testing"
fileName="$1"
relativePath="/${s3Bucket}/${fileName}"
contentType="application/octet-stream"
stringToSign="PUT\n\n${contentType}\n${dateFormatted}\n${relativePath}"
s3AccessKey="AKIARXP3OARBM3PCL6JV"
s3SecretKey="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"
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3SecretKey} -binary | base64`
curl -v -X PUT -T "${fileName}" \
-H "Host: ${s3Bucket}.s3.us-east-1.amazonaws.com" \
-H "Date: ${dateFormatted}" \
-H "Content-Type: ${contentType}" \
-H "Authorization: AWS ${s3AccessKey}:${signature}" \
https://${s3Bucket}.s3.us-east-1.amazonaws.com/${fileName}
