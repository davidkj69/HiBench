#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#export HADOOP_HOME=
#export JAVA_HOME=/usr/lib/jvm/default-java
export JAVA_HOME=/usr/jdk64/jdk1.6.0_31

this="${BASH_SOURCE-$0}"
bin=$(cd -P -- "$(dirname -- "$this")" && pwd -P)
script="$(basename -- "$this")"
this="$bin/$script"

export HIBENCH_VERSION="2.2"

###################### Global Paths ##################

HADOOP_EXECUTABLE=/usr/bin/hadoop 
HADOOP_CONF_DIR=/etc/hadoop/conf
# HADOOP_EXAMPLES_JAR=/usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples-2.2.0.2.0.6.0-76.jar
HADOOP_EXAMPLES_JAR=/usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples-2.2.0.2.0.10.0-1.jar
HIBENCH_HOME=/opt/HiBench
HIVE_HOME=/usr
MAHOUT_HOME=/usr/lib/mahout

if [ -n "$HADOOP_HOME" ]; then
	HADOOP_EXECUTABLE=$HADOOP_HOME/bin/hadoop
fi 					

if $HADOOP_EXECUTABLE version|grep -i -q cdh4; then
	HADOOP_VERSION=cdh4
elif $HADOOP_EXECUTABLE version|grep -i -q "hadoop 2"; then
  HADOOP_VERSION=hadoop2
else
	HADOOP_VERSION=hadoop1
fi

if [ "x"$HADOOP_VERSION == "xhadoop2" ]; then
   # HADOOP_EXAMPLES_JAR=/usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples-2.2.0.2.0.6.0-76.jar
   HADOOP_EXAMPLES_JAR=/usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples-2.2.0.2.0.10.0-1.jar
   MAPRED_EXECUTABLE=/usr/bin/mapred

  CONFIG_REDUCER_NUMBER=mapreduce.job.reduces
  CONFIG_MAP_NUMBER=mapreduce.job.maps
else
  export HADOOP_CONF_DIR=$HADOOP_HOME/conf
  HADOOP_EXAMPLES_JAR=$HADOOP_HOME/hadoop-examples*.jar

  CONFIG_REDUCER_NUMBER=mapred.reduce.tasks
  CONFIG_MAP_NUMBER=mapred.map.tasks
fi

echo HADOOP_EXECUTABLE=${HADOOP_EXECUTABLE:? "ERROR: Please set paths in $this before using HiBench."}
echo HADOOP_CONF_DIR=${HADOOP_CONF_DIR:? "ERROR: Please set paths in $this before using HiBench."}
echo HADOOP_EXAMPLES_JAR=${HADOOP_EXAMPLES_JAR:? "ERROR: Please set paths in $this before using HiBench."}

if [ -z "$HIBENCH_HOME" ]; then
    export HIBENCH_HOME=`dirname "$this"`/..
fi

if [ -z "$HIBENCH_CONF" ]; then
    export HIBENCH_CONF=${HIBENCH_HOME}/conf
fi

if [ -f "${HIBENCH_CONF}/funcs.sh" ]; then
    . "${HIBENCH_CONF}/funcs.sh"
fi

if [ -z "$HIVE_HOME" ]; then
    export HIVE_HOME=${HIBENCH_HOME}/common/hive-0.9.0-bin
fi

if [ -z "$MAHOUT_HOME" ]; then
    export MAHOUT_HOME=${HIBENCH_HOME}/common/mahout-distribution-0.7-$HADOOP_VERSION
fi

if [ -z "$NUTCH_HOME" ]; then
    export NUTCH_HOME=${HIBENCH_HOME}/nutchindexing/nutch-1.2-$HADOOP_VERSION
fi

if [ -z "$DATATOOLS" ]; then
    export DATATOOLS=${HIBENCH_HOME}/common/autogen/dist/datatools.jar
fi

if [ $# -gt 1 ]
then
    if [ "--hadoop_config" = "$1" ]
          then
              shift
              confdir=$1
              shift
              HADOOP_CONF_DIR=$confdir
    fi
fi
HADOOP_CONF_DIR="${HADOOP_CONF_DIR:-$HADOOP_HOME/conf}"

# base dir HDFS
export DATA_HDFS=/tmp/HiBench

# local report
export HIBENCH_REPORT=${HIBENCH_HOME}/hibench.report

################# Compress Options #################
# swith on/off compression: 0-off, 1-on
export COMPRESS_GLOBAL=1
export COMPRESS_CODEC_GLOBAL=org.apache.hadoop.io.compress.DefaultCodec
#export COMPRESS_CODEC_GLOBAL=com.hadoop.compression.lzo.LzoCodec
#export COMPRESS_CODEC_GLOBAL=org.apache.hadoop.io.compress.SnappyCodec

################# Summary Report Options #################
export GENERATE_SUMMARY=1
