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
BIN=`cd "${DIR}/../"; pwd`

# Prepare
. $DIR/prepare.sh

for idx in {1..14}; do

   NOW=$(date +"%m-%d-%Y_%H_%M_%S")

   if [ -f $HIBENCH_REPORT ]; then
      cat $HIBENCH_REPORT | sort | sed 's/[[:space:]]\+/,/g' | grep -v "Type" >> $HIBENCH_REPORT.$NOW.csv
      $HADOOP_EXECUTABLE fs -copyFromLocal $HIBENCH_REPORT.$NOW.csv $BENCHMARKING_RESULTS_HDFS_DIR
      rm -f $HIBENCH_REPORT.$NOW.csv
      rm -f $HIBENCH_REPORT
   fi

   # This command deletes the $HIBENCH_REPORT file
   $BIN/run-all.sh

done

# Get the last result now.....
if [ -f $HIBENCH_REPORT ]; then
  cat $HIBENCH_REPORT | sort | sed 's/[[:space:]]\+/,/g' | grep -v "Type" >> $HIBENCH_REPORT.$NOW.csv
  $HADOOP_EXECUTABLE fs -copyFromLocal $HIBENCH_REPORT.$NOW.csv $BENCHMARKING_RESULTS_HDFS_DIR
  rm -f $HIBENCH_REPORT.$NOW.csv
  rm -f $HIBENCH_REPORT
fi

# Generate summary report
if [ $GENERATE_SUMMARY -eq 1 ]; then
   $DIR/bin/multi/generate-summary.sh
fi
