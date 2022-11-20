FROM debian:stable-slim

RUN apt update && apt install -y jq curl

COPY poller.sh /poller.sh