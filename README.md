# wowHoneypot-bunseki
## wowhoneypotのログを分析するプログラム
### warning
h_bash.shは最新コード触らない.<br>
触る場合には, 手動でpullを行う.<br>
行った後に<br>
```
chmod 707 h_bash.sh
```

## lambda

```python
import boto3
import os
import sys
import time

def ec2_start():
    ec2 = boto3.client('ec2', region_name=os.environ['region'])
    ec2.start_instances(InstanceIds=[os.environ['instance_id']])
    print('Instance ' + os.environ['instance_id'] + ' Started')

def ec2_stop():
    ec2 = boto3.client('ec2', region_name=os.environ['region'])
    ec2.stop_instances(InstanceIds=[os.environ['instance_id']])
    print('Instance ' + os.environ['instance_id'] + ' Stopped')

def ec2_run_command():
    args = sys.argv
    command = "../../home/ssm-user/wowHoneypot-bunseki/./h_bash.sh"
    ssm = boto3.client('ssm')
    r = ssm.send_command(
        InstanceIds=[os.environ['instance_id']],
        DocumentName = "AWS-RunShellScript",
        Parameters = {
            "commands": [command] 
        }
    )
    command_id = r['Command']['CommandId']
    ## 処理終了待ち
    time.sleep(5)
    res = ssm.list_command_invocations(
          CommandId = command_id,
          Details = True
      )
    invocations = res['CommandInvocations']
    status = invocations[0]['Status']
    if status == "Failed":
        print("Command実行エラー")
    account = invocations[0]['CommandPlugins'][0]['Output']
    print(account)
    

def main(event, context):
    print('ec2 start')
    ec2_start()
    time.sleep(10)
    print('run_command start')
    ec2_run_command()
    time.sleep(10)
    print('ec2 stop')
    ec2_stop()

```

## 分析フォーマット

```python
# %%
import pandas
import numpy as np
import matplotlib.pyplot as plt
import japanize_matplotlib
import datetime as dt
import base64
import warnings
warnings.simplefilter('ignore')

# %% [markdown]
# <h2>データの整形</h2>

# %%
dt_now=dt.datetime.now()
file_day=dt_now.strftime("%Y%m%d")
print(file_day)
columns=["day","time","IP","myip","status","status_code",'true or flase','user_agent']

'''
#本番用df
#df = pandas.read_csv('/input/log/log/'+str(file_day),delimiter=' ',names=columns)
#テスト用df
'''

df = pandas.read_csv('/home/ssm-user/wowHoneypot-bunseki/input/log/log/'+str(file_day)+'.txt',delimiter=' ',names=columns)
for i in range(len(df)):
    df['user_agent'][i]=base64.b64decode(df['user_agent'][i].encode())
df=df[['day','time','IP','status','status_code','user_agent']]

# %% [markdown]
# <h2>全体データ(上位5件)</h2>

# %%
file_day=dt_now - dt.timedelta(days=1)
file_day=file_day.strftime("%Y-%m-%d")
to_day=df[df['day']==str(file_day)]
#%H:%M:%S+%Z
to_day['time']=pandas.to_datetime(to_day['time'], format='%H:%M:%S%z')
to_day=to_day.reset_index()
to_day=to_day[['day','time','IP','status','status_code','user_agent']]


# %%
to_day.head()

# %% [markdown]
# <h2>当日のアクセスが多いディレクトリ</h2>

# %%
to_day.groupby('status').count().sort_values('status_code', ascending=False)['day']

# %% [markdown]
# <h2>アクセスの多いIP</h2>

# %%
ip=to_day.groupby('IP').count().sort_values('status_code', ascending=False)['day'][0:10]
ip

# %% [markdown]
# <h2>ファイル全体アクセスログ可視化(5分間合計)</h2>

# %%
to_day.groupby(pandas.Grouper(key='time', freq='05T')).count()['day'].plot(figsize=(100,4))

# %% [markdown]
# <h2>攻撃者の情報</h2>

# %%
print(len(ip))
for i in range(len(ip)):
    ip_list=to_day.groupby('IP').count().sort_values('status_code', ascending=False)['day'][0:10][i]
    print('https://www.abuseipdb.com/check/'+str(ip.index[i]))

```
### 自分で新たな分析を追加する場合
新たなライブラリを使う場合には, 

```
pip freeze > requirements.txt
```

## cd
コードの自動テストを行う場合には, .pyファイルをexportする.
