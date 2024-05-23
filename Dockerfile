FROM node:20.13.1-alpine3.19 as base

WORKDIR /app

COPY package*.json ./

#user group and user
RUN addgroup -S nodegroup && adduser -S nodeuser -G nodegroup

#dev stage
FROM base as dev
ENV NODE_ENV=development
RUN npm install
COPY . .
CMD ["npm", "run", "dev"]

#prod stage
FROM base as prod
ENV NODE_ENV=production
RUN npm install --only=production
COPY . .
WORKDIR /app/src

#user permission
RUN chown -R nodeuser:nodegroup /app/src
USER nodeuser

CMD ["node", "index.js"]