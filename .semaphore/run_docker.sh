#!/bin/bash

RUN_ID=$1

echo "Pulling Docker images..."
docker pull nduythanh1/selenium-chrome-app
docker pull nduythanh1/stream-app
docker pull nduythanh1/selenium-earnvids-app

echo "Starting 4 containers for RUN_ID: $RUN_ID"

# StreamHG A
timeout 7m docker run --rm \
  -e RUN_ID=${RUN_ID}_a \
  nduythanh1/stream-app > stream1_${RUN_ID}.log 2>&1 &

# StreamHG B
timeout 7m docker run --rm \
  -e RUN_ID=${RUN_ID}_b \
  nduythanh1/stream-app> stream2_${RUN_ID}.log 2>&1 &

# Earnvids A
timeout 7m docker run --rm \
  -e RUN_ID=${RUN_ID}_c \
  nduythanh1/selenium-earnvids-app > earn1_${RUN_ID}.log 2>&1 &

# Earnvids B
timeout 7m docker run --rm \
  -e RUN_ID=${RUN_ID}_d \
  nduythanh1/selenium-earnvids-app > earn2_${RUN_ID}.log 2>&1 &

wait
echo "All 4 containers finished for RUN_ID: $RUN_ID"

echo "Running additional container with timeout 15 minutes"
docker run -d --rm \
  --name selenium_${RUN_ID} \
  -e RUN_ID=${RUN_ID} \
  nduythanh1/selenium-chrome-app > cid.txt

CID=$(cat cid.txt)

(docker wait $CID & echo $! > wait_pid.txt) &

sleep 900 && echo "Timeout reached! Killing container..." && docker kill $CID || true

wait $(cat wait_pid.txt) || true

echo "Container completed or was terminated"
