#!/bin/bash

if [ -z "$API_URL" ] || [ -z "$DAG_RUN_ID" ] || [ -z "$DAG_ID" ]; then
  printf "This script requires an Airflow REST URL \"API_URL\", \"DAG_ID\" and \"DAG_RUN_ID\" environment variables set\n"
  exit 1
fi

STATE=""
function poll {
  if [ -z "$BASIC_AUTH" ]; then
    RESPONSE=$(curl -v -s ${API_URL}/api/v1/dags/${DAG_ID}/dagRuns/${DAG_RUN_ID})
  else
    RESPONSE=$(curl -v -s -H "Authorization: Basic ${BASIC_AUTH}" ${API_URL}/api/v1/dags/${DAG_ID}/dagRuns/${DAG_RUN_ID})
  fi
  STATE=$(echo "$RESPONSE" | jq -r '.state')
  printf "Status of DAG_RUN_ID ${DAG_RUN_ID} for DAG ${DAG_ID}: $STATE\n"
}

while [ "$STATE" = "" ] || [ "$STATE" = "queued" ] || [ "$STATE" = "running" ]; do
  sleep 3
  poll
done
if [ "$STATE" = "failed" ] || [ -z "$STATE" ]; then
  exit 1
fi