FROM node:25-alpine@sha256:d1cdf008963e1627f47c4426c33481e538190300ad2514e9f8d5c75755888521

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
