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
BASE=`cd "${DIR}/../.."; pwd`
DUMP_FILE=$DIR/dump-all.csv
BENCHMARKS_FILE=$DIR/benchmarks.lst

# Remove the previous list of benchmarks
if [ -f $BENCHMARKS_FILE ]; then
   rm -rf $BENCHMARKS_FILE
fi

# Get a list of all the benchmarks we have metrics for.....
hive -e 'select distinct(benchmark) from analysis;' > $BENCHMARKS_FILE

# Gather the metrics
for b in `cat $BENCHMARKS_FILE`; do
   for metric in duration throughput_bytes_per_sec; do
      if [ -f $BASE/$metric-summary.csv ]; then
         rm -rf $BASE/$metric-summary.csv
      fi

      CMD=`echo "hive -e 'select \"$b\", min($metric), max($metric), avg($metric), stddev_pop($metric), variance($metric), count(*) from analysis where benchmark = \"$b\";' | sed 's/[[:space:]]\+/,/g' >> $BASE/$metric-summary.csv"`
      eval $CMD
   done
done

# Clean up our mess
rm -f $BENCHMARKS_FILE

# Dump all of the csv files into one big one
if [ -f $DUMP_FILE ]; then
   rm -rf $DUMP_FILE
fi

hive -e 'select * from analysis' | sed 's/[[:space:]]\+/,/g' > $DUMP_FILE

