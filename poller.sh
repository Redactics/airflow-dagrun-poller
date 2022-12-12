#!/bin/bash

set -eo pipefail

if [ -z "$API_URL" ] || [ -z "$DAG_RUN_ID" ] || [ -z "$DAG_ID" ]; then
  printf "This script requires an Airflow REST URL \"API_URL\", \"DAG_ID\" and \"DAG_RUN_ID\" environment variables set\n"
  exit 1
fi

STATE=""
CONTINUATION_TOKEN=""
function poll {
  DAG_RUN_URL="${API_URL}/api/v1/dags/${DAG_ID}/dagRuns/${DAG_RUN_ID}"
  if [ ! -z "$TAIL_TASK_ID" ]; then
    TASK_INSTANCE_URL="${API_URL}/api/v1/dags/${DAG_ID}/dagRuns/${DAG_RUN_ID}/taskInstances/${TAIL_TASK_ID}/logs/1?full_content=true"
    if [ ! -z "$CONTINUATION_TOKEN" ]; then
      TASK_INSTANCE_URL+="&token=${CONTINUATION_TOKEN}"
    fi
  fi

  if [ -z "$BASIC_AUTH" ]; then
    RESPONSE=$(curl -f -S -s -H "Accept: application/json" $DAG_RUN_URL)
  else
    RESPONSE=$(curl -f -S -s -H "Accept: application/json" -H "Authorization: Basic ${BASIC_AUTH}" $DAG_RUN_URL)
  fi
  if [ $? -ne 0 ]; then
    exit 1
  fi
  STATE=$(echo "$RESPONSE" | jq -r '.state')
  if [ -z "$TAIL_TASK_ID" ]; then
    printf "Status of DAG_RUN_ID ${DAG_RUN_ID} for DAG ${DAG_ID}: $STATE\n"
  else
    # show log output of TAIL_TASK_ID
    if [ -z "$BASIC_AUTH" ]; then
      RESPONSE=$(curl -f -S -s -H "Accept: application/json" $TASK_INSTANCE_URL)
    else
      RESPONSE=$(curl -f -S -s -H "Accept: application/json" -H "Authorization: Basic ${BASIC_AUTH}" $TASK_INSTANCE_URL)
    fi
    if [ $? -ne 0 ]; then
      exit 1
    fi
    CONTINUATION_TOKEN=$(echo "$RESPONSE" | jq -r '.continuation_token')
    if [ -z "$CONTINUATION_TOKEN" ]; then
      # full logs returned
      LOGS=$(echo "$RESPONSE")
    else
      LOGS=$(echo "$RESPONSE" | jq -r '.content')
    fi
    printf "${LOGS}\n"
  fi
}

while [ "$STATE" = "" ] || [ "$STATE" = "queued" ] || [ "$STATE" = "running" ]; do
  sleep 3
  poll
done
if [ "$STATE" = "failed" ] || [ -z "$STATE" ]; then
  exit 1
fi