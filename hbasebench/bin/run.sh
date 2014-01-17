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

echo "========== running hbase bench =========="
# configure
DIR=`cd $bin/../; pwd`
. "${DIR}/../bin/hibench-config.sh"
. "${DIR}/conf/configure.sh"

check_compress

export JAVA_HOME=/usr/jdk64/jdk1.6.0_31

for benchmark in `cat $DIR/conf/benchmarks.lst`; do
    if [[ $benchmark == \#* ]]; then
        continue
    else

      echo "========== running hbase $benchmark =========="
      # Capture the start time
      START_TIME=`timestamp`

      # Run the Performance test
      $HBASE_EXECUTABLE $HBASE_CLASS --rows=$ROWS $benchmark $NUM_CLIENTS 

      # Capture the end time
      END_TIME=`timestamp`

      # A few other variables for the report
      let SIZE=$ROWS*$NUM_CLIENTS*1000
      BM_NAME=`echo $benchmark | tr [:lower:] [:upper:]`

      # Record the results
      gen_report "HBASE-$BM_NAME" ${START_TIME} ${END_TIME} ${SIZE}
    fi
done
