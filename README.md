# wowHoneypot-bunseki
## wowhoneypotのログを分析するプログラム
### warning
h_bash.shは最新コード触らない.<br>
触る場合には, 手動でpullを行う.<br>
行った後に<br>
```
chmod 707 h_bash.sh
```

## 分析フォーマット

```
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
