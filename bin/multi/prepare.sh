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

DIR=`dirname "$0"`
DIR=`cd "${DIR}/../.."; pwd`

HIVE_SCRIPT=$DIR/bin/multi/analysis-results-db.hive

# Pull in the configuration settings
. $DIR/bin/hibench-config.sh

# TODO Move this to the global file?
BENCHMARKING_RESULTS_HDFS_DIR=/benchmarking/results

# Make sure that the HDFS directory exists and if not, create it
$HADOOP_EXECUTABLE fs -mkdir -p $BENCHMARKING_RESULTS_HDFS_DIR

# Clear out the old hive script
if [ -f $HIVE_SCRIPT ]; then
  rm -f $HIVE_SCRIPT
fi

# Run the hive script that defines the schema and points the external location to $BENCHMARKING_RESULTS_HDFS_DIR
echo "DROP TABLE analysis;" >> $HIVE_SCRIPT
echo "CREATE EXTERNAL TABLE analysis (benchmark STRING, date STRING, time STRING, input_date_size BIGINT, duration FLOAT, throughput_bytes_per_sec BIGINT, throughput_bytes_per_node BIGINT) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LOCATION '$BENCHMARKING_RESULTS_HDFS_DIR/';" >> $HIVE_SCRIPT

# Create the analysis table
$HIVE_HOME/bin/hive -f $HIVE_SCRIPT

# TODO: Remove hive script now?


