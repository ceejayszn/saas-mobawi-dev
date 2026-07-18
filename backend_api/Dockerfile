FROM node:20-alpine

WORKDIR /app

# Install openssl for Prisma client compatibility on alpine
RUN apk add --no-cache openssl

COPY package*.json ./
RUN npm ci

COPY prisma ./prisma/
COPY tsconfig.json ./
COPY src ./src/

RUN npm run build

EXPOSE 3000

CMD ["npm", "run", "start"]
