#!/bin/sh

#git pull
git -C  wowHoneypot-bunseki/ pull
#ここで本当はaws s3のinputをする必要がある.
aws s3 cp s3://dev-honeypot-accesslog /home/ec2-user/wowHoneypot-bunseki/input
#ファイル名をここで決める
to_day=$(date +"%Y%m%d")
echo $to_day
#pipの更新
pip3 install -rrequirements.txt
#python jupiter出力
jupyter nbconvert --execute test.ipynb --output output/$to_day  --to html
#aws s3アップロード
aws s3 cp /output s3://dev-honeypot-output-data/ --recursive