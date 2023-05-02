#!/bin/sh

node ./assignment/user-service/dist/main.js &
node ./assignment/product-service/dist/main.js &
node ./assignment/payment-service/dist/main.js &
node ./assignment/api-gateway/dist/main.js