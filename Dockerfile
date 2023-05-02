# syntax=docker/dockerfile:1

###################
# BUILD FOR API GATEWAY
###################
FROM node:18-alpine AS api-gateway
WORKDIR /usr/src/app
COPY --chown=node:node ./api-gateway/package*.json ./


RUN npm ci
COPY --chown=node:node ./api-gateway .
RUN npm run build

ENV NODE_ENV production

RUN npm ci --only=production && npm cache clean --force

USER node
###################
# BUILD FOR USER SERVICE
###################
FROM node:18-alpine AS user-service
WORKDIR /usr/src/app
COPY --chown=node:node ./user-service/package*.json ./


RUN npm ci
COPY --chown=node:node ./user-service/ .
RUN npm run build

ENV NODE_ENV production

RUN npm ci --only=production && npm cache clean --force

USER node
###################
# BUILD FOR API GATEWAY
###################
FROM node:18-alpine AS product-service
WORKDIR /usr/src/app
COPY --chown=node:node ./product-service/package*.json ./


RUN npm ci
COPY --chown=node:node ./product-service/ .
RUN npm run build

ENV NODE_ENV production

RUN npm ci --only=production && npm cache clean --force

USER node
###################
# BUILD FOR API GATEWAY
###################
FROM node:18-alpine As payment-service
WORKDIR /usr/src/app
COPY --chown=node:node ./payment-service/package*.json ./


RUN npm ci
COPY --chown=node:node ./payment-service/ .
RUN npm run build

ENV NODE_ENV production

RUN npm ci --only=production && npm cache clean --force

USER node
###################
# PRODUCTION
###################

FROM node:18-alpine As prod

# Copy the bundled code from the build stage to the production image
ENV DB_HOST localhost

COPY --chown=node:node --from=api-gateway /usr/src/app/node_modules ./assignment/api-gateway/node_modules
COPY --chown=node:node --from=api-gateway /usr/src/app/dist ./assignment/api-gateway/dist
COPY --chown=node:node --from=user-service /usr/src/app/node_modules ./assignment/user-service/node_modules
COPY --chown=node:node --from=user-service /usr/src/app/dist ./assignment/user-service/dist
COPY --chown=node:node --from=product-service /usr/src/app/node_modules ./assignment/product-service/node_modules
COPY --chown=node:node --from=product-service /usr/src/app/dist ./assignment/product-service/dist
COPY --chown=node:node --from=payment-service /usr/src/app/node_modules ./assignment/payment-service/node_modules
COPY --chown=node:node --from=payment-service /usr/src/app/dist ./assignment/payment-service/dist

COPY --chown=node:node ./init.sh ./assignment/
# Start the server using the production build
CMD [ "sh", "./assignment/init.sh" ]
EXPOSE 3000
EXPOSE 3011
EXPOSE 3012
EXPOSE 3013