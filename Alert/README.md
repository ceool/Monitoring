## 그라파나에서 이미지를 포함한 Alert

### 이미지 렌더링 플러그인 설치
```
# grafana-cli plugins install grafana-image-renderer
```

<br>

### 로그 관련 수정
```
# vim /etc/grafana/grafana.ini

---------------------------------------
[log]
filters = rendering:debug

[plugin.grafana-image-renderer]
rendering_ignore_https_errors = true
---------------------------------------
```

<br>

### 서버 재시작 및 이미지 렌더링 확인
```
# service grafana-server restart
```

![22](https://user-images.githubusercontent.com/62891711/114642174-64bad180-9d0e-11eb-9479-aa0e569dd14c.png) <br>
그라파나 웹에 접속 후, 확인

<br>

### 오류 발생 시
```
# cat /var/log/grafana/grafana.log


t=2021-04-13T04:55:16+0000 lvl=eror msg="Render request failed" logger=plugins.backend pluginId=grafana-image-renderer url="http://localhost:3000/d-solo/rYdddlPWk/node-exporter-full?orgId=1&refresh=1m&from=1618203315074&to=1618289715074&panelId=77&width=1000&height=500&tz=Asia%2FSeoul&render=1" error="Error: Failed to launch chrome!\n/var/lib/grafana/plugins/grafana-image-renderer/chrome-linux/chrome: error while loading shared libraries: libXcomposite.so.1: cannot open shared object file: No such file or directory\n\n\nTROUBLESHOOTING: https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md\n"
```

위와 같은 오류가 발생하면, ldd 명령어로 요구하는 공유 라이브러리(shared libraries)를 찾아내서 해결합니다.

<br>

```
# cd /var/lib/grafana/plugins/grafana-image-renderer
# ldd chrome-linux/chrome | grep 'not found'

---------------------------------------------
        libXcomposite.so.1 => not found
        libXdamage.so.1 => not found
        libXtst.so.6 => not found
        libcups.so.2 => not found
        libXss.so.1 => not found
        libasound.so.2 => not found
        libatk-1.0.so.0 => not found
        libatk-bridge-2.0.so.0 => not found
        libpangocairo-1.0.so.0 => not found
        libpango-1.0.so.0 => not found
        libcairo.so.2 => not found
        libatspi.so.0 => not found
        libgtk-3.so.0 => not found
        libgdk-3.so.0 => not found
        libgdk_pixbuf-2.0.so.0 => not found
---------------------------------------------
```

#### 필요한 라이브러리 설치
```
yum -y install libalsa* libgtk* libXss* libatk-bridge* 
```

#### ldd 명령어로 다시 확인
```
# ldd chrome-linux/chrome | grep 'not found'

## 아무것도 출력되지 않으면 됩니다.
```
그리고, 서버 재시작 및 그라파나 웹에 접속하여 이미지 렌더링이 작동하는지 확인합니다. <br>

<br>

### 이메일 설정
```
# vim /etc/grafana/grafana.ini

--------------------------------------------
[smtp]
enabled = true
host = smtp.gmail.com:587
user = Your_ID@gmail.com
password = password
skip_verify = true
from_address = Your_ID@gmail.com
from_name = Grafana


[server]
root_url = http://Your_Host:3000/
--------------------------------------------
```
Alert에서 보여주는 localhost를 수정하려면 root_url을 수정해야합니다.

<br>

### 서버 재시작
```
# service grafana-server restart
```

<br><br>

### 경보(Alert) 테스트 [텔레그램]

![1](https://user-images.githubusercontent.com/62891711/114643674-1a871f80-9d11-11eb-8346-e059ab8b516b.png) <br>

이미지와 같이 Alert가 오며 root_url 수정 후, localhost가 변경된 모습.

<br>

### 경보(Alert) 테스트 [이메일]

![12](https://user-images.githubusercontent.com/62891711/114643864-6df96d80-9d11-11eb-8070-f30e5419cdc1.png)
![13](https://user-images.githubusercontent.com/62891711/114643721-2ecb1c80-9d11-11eb-9660-9422c6f71f0e.png)

