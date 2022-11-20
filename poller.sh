#!/bin/bash

if [ -z "$API_URL" ] || [ -z "$DAG_RUN_ID" ] || [ -z "$DAG_ID" ]; then
  printf "This script requires an Airflow REST URL \"API_URL\", \"DAG_ID\" and \"DAG_RUN_ID\" environment variables set\n"
  exit 1
fi

STATE=""
function poll {
  if [ -z "$BASIC_AUTH" ]; then
    STATE=$(curl -s ${API_URL}/api/v1/dags/${DAG_ID}/dagRuns/${DAG_RUN_ID} | jq -r '.state')
  else
    STATE=$(curl -s -H "Authorization: Basic ${BASIC_AUTH}" ${API_URL}/api/v1/dags/${DAG_ID}/dagRuns/${DAG_RUN_ID} | jq -r '.state')
  fi
  printf "Status of DAG_RUN_ID ${DAG_RUN_ID} for DAG ${DAG_ID}: $STATE\n"
}

while [ "$STATE" != "success" ]; do
  sleep 3
  poll
done