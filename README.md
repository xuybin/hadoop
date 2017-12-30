# xuybin/hadoop
## Run Hadoop cluster with docker-compose
```bash
curl -L -s https://raw.githubusercontent.com/xuybin/hadoop/master/docker-compose.yml >docker-compose.yml && docker-compose up -d
docker exec -it  hadoop-master /bin/bash
  ./start-hadoop.sh
  exit
docker-compose ps
```

### Optional 
```bash
docker ps
docker network ls
docker network ls
docker volume inspect **_hdfs-master[slave1,slave2]
docker network inspect  **_hadoop
```

## Verification Hadoop cluster
```bash
NameNode:visit http://ip:8098
ResourceManager:visit http://ip:8099
```
## Stop Hadoop cluster
```bash
docker exec -it  hadoop-master /bin/bash
  ./stop-hadoop.sh
  exit
docker-compose stop
docker-compose rm
```
