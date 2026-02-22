FROM node:22-bookworm-slim

WORKDIR /app

ENV NODE_ENV=production

RUN apt-get update \
  && apt-get install -y --no-install-recommends python3 make g++ curl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY package.json package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts

COPY src ./src
COPY bin ./bin
COPY public ./public
COPY config.example.json ./config.example.json
COPY LICENSE ./LICENSE
COPY README.md ./README.md

EXPOSE 8080

CMD ["npm", "start"]
