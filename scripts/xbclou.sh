
#script to generate access token
aws sts assume-role --role-arn arn:aws:iam::119175775298:role/rahumalikRole --role-session-name "RoleSession1" --profile rahulmaliktest

export ENDPOINT="s3.amazonaws.com" 
export ACCESS_KEY_ID="AKIARXP3OARBM3PCL6JV"
export SECRET_ACCESS_KEY="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" 
--s3-bucket=operator-testing
#script to upload to s3

xbcloud delete s3://rahulmaliktest/deepak
$XC --backup --stream=xbstream | xbcloud put s3://rahulmaliktest/deepak

xbcloud --storage=s3 --s3-bucket=rahulmaliktest delete rahultest7
$XC --backup --stream=xbstream | xbcloud --storage=s3 --s3-bucket=rahulmaliktest put rahultest7  2>&1 | tee $LOGDIR/xbcloud_$BX.log

#minio
#how to start minio server 
minio server /home/rahul.malik/minio_data
export ACCESS_KEY_ID=minioadmin && export SECRET_ACCESS_KEY=minioadmin && export ENDPOINT=http://192.168.1.37:9000
XBCLOUD_CREDENTIALS="--storage=s3  --s3-bucket=testbucket --s3-access-key=minioadmin --s3-secret-key=minioadmin --s3-endpoint=http://192.168.1.37:9000"

export XBCLOUD_CREDENTIALS="--storage=s3  --s3-bucket=operator-testing --s3-access-key=AKIARXP3OARBM3PCL6JV --s3-secret-key=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 --s3-endpoint=s3.amazonaws.com --s3-storage-class=STANDARD_IA"

#command to delete execute 
xbcloud delete abc $XBCLOUD_CREDENTIALS

google
xbcloud get --storage=google  --google-bucket=operator-testing --google-access-key=GOOGHBR3OBOI6H66MNT4IGA2  --google-secret-key=r9EPt5Goilutceqw2r1SVKxAUoMHhcvHcj7erg4y  abc

google test
export XBCLOUD_CREDENTIALS="--storage=google  --google-bucket=operator-testing --google-access-key=GOOGHBR3OBOI6H66MNT4IGA2  --google-secret-key=r9EPt5Goilutceqw2r1SVKxAUoMHhcvHcj7erg4y --google-storage-class=NEARLINE"
