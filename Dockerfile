# Install the app dependencies in a full Node docker image
FROM registry.access.redhat.com/ubi8/nodejs-18:latest as base
WORKDIR /usr/src/app

COPY . .
RUN npm install -g pnpm
# Install app dependencies
RUN \
  if [ -f pnpm-lock.yaml ]; then pnpm install --frozen-lockfile; \
  else pnpm install; \
  fi

RUN pnpm run build

# Copy the dependencies into a Slim Node docker image
FROM registry.access.redhat.com/ubi8/nodejs-18-minimal:latest as production
WORKDIR /usr/src/app
RUN npm install -g pnpm

# Install app dependencies
COPY --from=base /usr/src/app/node_modules ./node_modules
COPY --from=base /usr/src/app/dist ./dist

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
ENV PORT 3001

CMD ["pnpm", "start:prod"]
