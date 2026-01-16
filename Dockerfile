FROM node:25-alpine@sha256:e80397b81fa93888b5f855e8bef37d9b18d3c5eb38b8731fc23d6d878647340f

RUN apk add --no-cache git jq bash tini \
  && npm install -g npm@11.7.0

# Create the working directory and set permissions
WORKDIR /repo
RUN chown nobody:nobody /repo

COPY entrypoint.sh /entrypoint.sh

# Configure NPM to use a writable cache directory (since 'nobody' home is /)
ENV NPM_CONFIG_CACHE=/tmp/.npm

# Switch to non-root user
USER nobody

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/entrypoint.sh"]
