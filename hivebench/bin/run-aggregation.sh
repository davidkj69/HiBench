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

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

echo "========== running hive-aggregate bench =========="
# configure
DIR=`cd $bin/../; pwd`
. "${DIR}/../bin/hibench-config.sh"
. "${DIR}/conf/configure.sh"

echo "INPUT_HDFS=$INPUT_HDFS"

# path check
rm -rf ${DIR}/metastore_db
rm -rf ${DIR}/TempStatsStore
$HADOOP_EXECUTABLE $RMDIR_CMD /user/hive/warehouse/uservisits_aggre
# $HADOOP_EXECUTABLE $RMDIR_CMD /tmp

# pre-running
# echo "USE default;" > $DIR/hive-benchmark/uservisits_aggre.hive
echo "set mapred.map.tasks=$NUM_MAPS;" >> $DIR/hive-benchmark/uservisits_aggre.hive
echo "set mapred.reduce.tasks=$NUM_REDS;" >> $DIR/hive-benchmark/uservisits_aggre.hive
echo "set hive.stats.autogather=false;" >> $DIR/hive-benchmark/uservisits_aggre.hive

if [ $COMPRESS -eq 1 ]; then
    echo "set mapreduce.output.fileoutputformat.compress=true;" >> $DIR/hive-benchmark/uservisits_aggre.hive
    echo "set hive.exec.compress.output=true;" >> $DIR/hive-benchmark/uservisits_aggre.hive
    echo "set mapreduce.output.fileoutputformat.compress.type=BLOCK;" >> $DIR/hive-benchmark/uservisits_aggre.hive
    echo "set mapreduce.output.fileoutputformat.compress.codec=$COMPRESS_CODEC;" >> $DIR/hive-benchmark/uservisits_aggre.hive
fi

echo "DROP TABLE uservisits;" >> $DIR/hive-benchmark/uservisits_aggre.hive
echo "DROP TABLE uservisits_aggre;" >> $DIR/hive-benchmark/uservisits_aggre.hive
echo "CREATE EXTERNAL TABLE uservisits (sourceIP STRING,destURL STRING,visitDate STRING,adRevenue DOUBLE,userAgent STRING,countryCode STRING,languageCode STRING,searchWord STRING,duration INT ) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS SEQUENCEFILE LOCATION '$INPUT_HDFS/uservisits';">> $DIR/hive-benchmark/uservisits_aggre.hive
cat $DIR/hive-benchmark/uservisits_aggre.template >> $DIR/hive-benchmark/uservisits_aggre.hive

SIZE=`dir_size $INPUT_HDFS/uservisits`
START_TIME=`timestamp`

echo "SIZE=$SIZE"
echo "START_TIME=$START_TIME"

# run bench
$HIVE_HOME/bin/hive -f $DIR/hive-benchmark/uservisits_aggre.hive

# post-running
END_TIME=`timestamp`

echo "END_TIME=$END_TIME"

gen_report "HIVEAGGR" ${START_TIME} ${END_TIME} ${SIZE}

$HADOOP_EXECUTABLE fs -rm -r $OUTPUT_HDFS/hive-aggre
$HADOOP_EXECUTABLE fs -cp /user/hive/warehouse/uservisits_aggre $OUTPUT_HDFS/hive-aggre
