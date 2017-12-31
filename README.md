# xuybin/hadoop
![hadoop](https://raw.githubusercontent.com/xuybin/hadoop/master/hadoop.png)
## Run Hadoop cluster with docker-compose
In China
```bash
docker rmi -f registry.cn-shenzhen.aliyuncs.com/xuybin/hadoop && curl -L -s https://raw.githubusercontent.com/xuybin/hadoop/master/docker-compose-aliyun.yml >docker-compose.yml && docker-compose up -d
docker exec -it  hadoop-master /bin/bash
    ./start-hadoop.sh
    exit
docker-compose ps
```
Outside China
```bash
docker rmi -f xuybin/hadoop &&curl -L -s https://raw.githubusercontent.com/xuybin/hadoop/master/docker-compose.yml >docker-compose.yml && docker-compose up -d
docker exec -it  hadoop-master /bin/bash
    ./start-hadoop.sh
    exit
docker-compose ps
```

### Optional 
```bash
docker ps
docker network ls
docker network inspect  **_hadoop
docker volume ls
docker volume inspect **_hdfs-master[slave1,slave2]
```

## Verification Hadoop cluster
```bash
NameNode:visit http://ip:8098
ResourceManager:visit http://ip:8099
```

## Test Hadoop cluster
```bash
mkdir src &&echo "from f1 content" >src/f1.txt && echo "from f2 content" >src/f2.txt
hadoop fs -mkdir -p target && hdfs dfs -put ./src/* target
hdfs dfs -cat target/f1.txt
hdfs dfs -cat target/f2.txt
hadoop jar /hadoop/share/hadoop/mapreduce/sources/hadoop-mapreduce-examples-2.7.5-sources.jar org.apache.hadoop.examples.WordCount target target2
hdfs dfs -cat target2/*
```

## Stop Hadoop cluster
```bash
docker exec -it  hadoop-master /bin/bash
    ./stop-hadoop.sh
    exit
docker-compose stop
```

## Clean Hadoop cluster
```bash
docker-compose rm -f
docker volume ls
docker volume rm **_hdfs-master[slave1,slave2]
docker network ls
docker network rm  **_hadoop
```
