FROM node:20-alpine

WORKDIR /app

# Install openssl for Prisma client compatibility on alpine
RUN apk add --no-cache openssl

COPY package*.json ./
RUN npm ci

COPY prisma ./prisma/
RUN npx prisma generate

COPY . .

EXPOSE 3000

CMD ["npx", "ts-node", "src/index.ts"]
