FROM node:20-slim AS builder

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

FROM node:20-slim

WORKDIR /app
COPY --from=builder /app /app

EXPOSE 8080
CMD ["npm", "start"]