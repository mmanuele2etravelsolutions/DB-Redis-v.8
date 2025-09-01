#!/bin/bash

sudo docker run -d \
  --name redis_server_8.2.1 \
  --restart always \
  -p 6380:6379 \
  -v /var/lib/redis:/data \
  redis:8.2.1-alpine3.22 \
  redis-server \
    --requirepass "XXXXXXXXXX" \
    --bind 0.0.0.0 \
    --appendonly yes
