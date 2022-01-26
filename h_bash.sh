!/bin/sh
#git pull
#git -C  wowHoneypot-bunseki/ pull
git -C ../../../../home/ubuntu/wowHoneypot-bunseki/ pull
#ここで本当はaws s3のinputをする必要がある.
aws s3 cp s3://dev-honeypot-accesslog ../../../../home/ubuntu/wowHoneypot-bunseki/input/log --exclude"" --include ".txt" --recursive
#ファイル名をここで決める
to_day=$(date +"%Y%m%d")
echo $to_day
#pipの更新
pip3 install -r ../../../../home/ubuntu/wowHoneypot-bunseki/requirements.txt
#python jupiter出力
jupyter nbconvert --execute ../../../../home/ubuntu/wowHoneypot-bunseki/test.ipynb --output output/$to_day  --to html
#aws s3アップロード
aws s3 cp ../../../../home/ubuntu/wowHoneypot-bunseki/output s3://dev-honeypot-output-data/ --recursiv