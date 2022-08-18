###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:16 As development

# Create app directory
WORKDIR /usr/src/app

# Copy application dependency manifests to the container image.
# A wildcard is used to ensure copying both package.json AND package-lock.json (when available).
# Copying this first prevents re-running npm install on every code change.
COPY --chown=node:node package*.json ./

# # default to port 19006 for node, and 19001 and 19002 (tests) for debug
# ARG PORT=19006
# ENV PORT $PORT
# EXPOSE $PORT 19000 19001 19002
# RUN npm install -g npm

# Install app dependencies using the `npm ci` command instead of `npm install`
RUN npm ci

# Bundle app source
COPY --chown=node:node . .

# Use the node user from the image (instead of the root user)
USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:16 As build

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

# In order to run `npm run build` we need access to the Expo CLI and EAS CLI.
# Both are dev dependencies,
# In the previous development stage we ran `npm ci` which installed all dependencies.
# So we can copy over the node_modules directory from the development image into this build image.
COPY --chown=node:node --from=development /usr/src/app/node_modules ./node_modules

COPY --chown=node:node . .

# Run the build command which creates the production bundle
RUN npm run build:web

# Set NODE_ENV environment variable
ENV NODE_ENV production

# # install dependencies first, in a different location for easier app bind mounting for local development
# # due to default /opt permissions we have to create the dir with root and change perms
# RUN mkdir /opt/react_native_app
# WORKDIR /opt/react_native_app
# ENV PATH /opt/react_native_app/.bin:$PATH
# COPY ./react_native_app/package.json ./react_native_app/package-lock.json ./
# RUN npm install

# Running `npm ci` removes the existing node_modules directory.
# Passing in --only=production ensures that only the production dependencies are installed.
# This ensures that the node_modules directory is as optimized as possible.
RUN npm ci --only=production && npm cache clean --force

USER node

###################
# PRODUCTION
###################

FROM node:16 As production

# # for development, we bind mount volumes; comment out for production
# COPY ./react_native_app .

# Copy the bundled code from the build stage to the production image
COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/web-build ./web-build

# ENTRYPOINT ["npm", "run"]
CMD ["npx", "serve", "web-build"]