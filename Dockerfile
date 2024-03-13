# Install the app dependencies in a full Node docker image
FROM registry.access.redhat.com/ubi8/nodejs-18 as base
WORKDIR /usr/src/app


COPY --chown=1001:1001 package*.json ./
COPY --chown=1001:1001 pnpm*.yaml/ ./

RUN npm install -g pnpm
# Install app dependencies
RUN \
  if [ -f pnpm-lock.yaml ]; then pnpm install --frozen-lockfile; \
  else pnpm install; \
  fi

COPY --chown=1001:1001 tsconfig*.json ./
COPY --chown=1001:1001 src src
RUN pnpm run build

# Copy the dependencies into a Slim Node docker image
FROM registry.access.redhat.com/ubi8/nodejs-18-minimal as production
WORKDIR /usr/src/app
RUN npm install -g pnpm

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
ENV PORT 3001

# Install app dependencies
COPY --chown=1001:1001 --from=base /usr/src/app/package*.json/ .
COPY --chown=1001:1001 --from=base /usr/src/app/pnpm*.yaml/ .
RUN pnpm install --frozen-lockfile
COPY --chown=1001:1001 --from=base /usr/src/app/dist/ dist/

CMD ["pnpm", "start:prod"]
