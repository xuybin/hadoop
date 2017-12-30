FROM alpine:latest

VOLUME ["/hdfs"]
ARG slaveNum=2
RUN VER=2.7.5 \
 && URL1="https://mirrors.aliyun.com/apache/hadoop/common/hadoop-$VER/hadoop-$VER.tar.gz" \
 && URL2="http://archive.apache.org/dist/hadoop/common/hadoop-$VER/hadoop-$VER.tar.gz" \

 && apk --update add --no-cache wget tar openssh bash openjdk8 \
 && (wget -t 10 --max-redirect 1 --retry-connrefused -O "hadoop-$VER.tar.gz" "$URL1" || \
		 wget -t 10 --max-redirect 1 --retry-connrefused -O "hadoop-$VER.tar.gz" "$URL2") \
		  
 && sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd \
 && ssh-keygen -A \
 && ssh-keygen -t rsa -f /root/.ssh/id_rsa -P '' \
 && cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys \
 && { \
		 echo 'Host *'; \
		 echo '  UserKnownHostsFile /dev/null'; \
		 echo '  StrictHostKeyChecking no'; \
		 echo '  LogLevel quiet'; \
	  } > /root/.ssh/config \
	  		 
 && mkdir -p /hadoop /hdfs/namenode /hdfs/datanode  /hdfs/tmp \
 && tar zxf hadoop-$VER.tar.gz -C /hadoop --strip 1 \
 && sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/default-jvm\nexport HADOOP_PREFIX=/hadoop\nexport HADOOP_HOME=/hadoop\n:' /hadoop/etc/hadoop/hadoop-env.sh \
 && sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/hadoop/etc/hadoop/:' /hadoop/etc/hadoop/hadoop-env.sh \

 && echo -e  '<?xml version="1.0"?>\n<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>\n'\
'<configuration>\n'\
'    <property>\n'\
'        <name>dfs.namenode.name.dir</name>\n'\
'        <value>file:///hdfs/namenode</value>\n'\
'    </property>\n'\
'    <property>\n'\
'        <name>dfs.datanode.data.dir</name>\n'\
'        <value>file:///hdfs/datanode</value>\n'\
'    </property>\n'\
'    <property>\n'\
'        <name>dfs.replication</name>\n'\
'        <value>2</value>\n'\
'    </property>\n'\
'</configuration>\n'\
>/hadoop/etc/hadoop/hdfs-site.xml \


 && echo -e  '<?xml version="1.0"?>\n<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>\n'\
'<configuration>\n'\
'    <property>\n'\
'        <name>mapreduce.framework.name</name>\n'\
'        <value>yarn</value>\n'\
'    </property>\n'\
'</configuration>\n'\
>/hadoop/etc/hadoop/mapred-site.xml \

 && echo -e  '<?xml version="1.0"?>\n<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>\n'\
'<configuration>\n'\
'    <property>\n'\
'        <name>fs.defaultFS</name>\n'\
'        <value>hdfs://hadoop-master:9000/</value>\n'\
'    </property>\n'\
'    <property>\n'\
'        <name>hadoop.tmp.dir</name>\n'\
'        <value>/hdfs/tmp</value>\n'\
'    </property>\n'\
'</configuration>\n'\
>/hadoop/etc/hadoop/core-site.xml \

 && echo -e  '<?xml version="1.0"?>\n<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>\n'\
'<configuration>\n'\
'    <property>\n'\
'        <name>yarn.nodemanager.aux-services</name>\n'\
'        <value>mapreduce_shuffle</value>\n'\
'    </property>\n'\
'    <property>\n'\
'        <name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name>\n'\
'        <value>org.apache.hadoop.mapred.ShuffleHandler</value>\n'\
'    </property>\n'\
'    <property>\n'\
'        <name>yarn.resourcemanager.hostname</name>\n'\
'        <value>hadoop-master</value>\n'\
'    </property>\n'\
'</configuration>\n'\
>/hadoop/etc/hadoop/yarn-site.xml \

 && awk "BEGIN{for(i=1; i <= $slaveNum; i++) print \"hadoop-slave\"i}" >/hadoop/etc/hadoop/slaves \

 && echo -e '#!/bin/bash\n'\
'/hadoop/sbin/start-dfs.sh\n'\
'/hadoop/sbin/start-yarn.sh\n'\
>/start-hadoop.sh \
 && chmod -v +x /start-hadoop.sh \
 
 && echo -e '#!/bin/bash\n'\
'/hadoop/sbin/stop-dfs.sh\n'\
'/hadoop/sbin/stop-yarn.sh\n'\
>/stop-hadoop.sh \
 && chmod -v +x /stop-hadoop.sh \

 && echo -e '#!/bin/bash\n'\
'if [ ! -d "/hdfs/namenode"]; then\n'\
'    mkdir -p /hdfs/namenode /hdfs/datanode  /hdfs/tmp\n'\
'    /hadoop/bin/hdfs namenode -format\n'\
'fi\n'\
'/usr/sbin/sshd\n -D\n'\
>/entrypoint.sh \
 && chmod -v +x /entrypoint.sh \
 
 
 && apk del wget tar \
 && rm -rf /hadoop/share/doc /hadoop-$VER.tar.gz \
 && rm -rf /var/cache/apk/* /tmp/* \
 

ENTRYPOINT ["/entrypoint.sh"]

# EXPOSE 8020 8042 8088 9000 10020 19888 50010 50020 50070 50075 50090