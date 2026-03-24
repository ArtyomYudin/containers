#!/bin/sh

echo "Starting ReverseApiServer as service..."
/opt/reverse-api/ReverseApiServer &

pid=$!

term() {
  echo "Stopping ReverseApiServer (service mode)..."
  /opt/reverse-api/ReverseApiServer -t
  wait "$pid"
}

trap term TERM INT
wait "$pid"
