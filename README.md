

## 그라파나
![22](https://user-images.githubusercontent.com/62891711/114481827-5f8f5100-9c40-11eb-842e-3b223958e2c0.png)

```
http://host_ip:3000
```

<br>

## 프로메테우스 + node_exporter
![그림2](https://user-images.githubusercontent.com/62891711/114482526-acbff280-9c41-11eb-965a-4702b15d6e66.png)
```
prometheus: http://host_ip:9090/targets
node_exporter: http://host_ip:9100/metrics (curl localhost:9100/metrics)
```

<br>

## loki + promtail
![3](https://user-images.githubusercontent.com/62891711/114481257-2a363380-9c3f-11eb-8939-3cf4faeaaf99.png)

```
loki: http://host_ip:3100/metrics (curl localhost:3100/metrics)
promtail: http://host_ip:9080/targets (*sh 파일로 포트 수정)
```



수집한 모니터링 정보를 그라파나가 보여줌.
![2](https://user-images.githubusercontent.com/62891711/114481586-d8da7400-9c3f-11eb-9825-31ac27ce8780.png)

```
모니터링할 서버에 설치해야되는 것: node_exporter, promtail
```
이외에도 Telegraf & InfluxDB 연동이 있음.
