# Stage 1: Build the Rails app
FROM ruby:2.6.10-bullseye as builder

# Set environment variables
ENV LANG=C.UTF-8 \
    RAILS_ENV=production \
    BUNDLE_PATH=/bundle \
    BUNDLE_JOBS=4

# set the working directory
WORKDIR /repo

# copy the Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN gem install bundler -v 2.4.22 && \
    bundle install --without development test

# Stage 2: Create a smaller image with Debian Bullseye
FROM ruby:2.6.10-slim-bullseye AS final

# Set environment variables
ENV LANG=C.UTF-8 \
    RAILS_ENV=production \
    BUNDLE_PATH=/bundle

# Install security updates
RUN apt-get update  \
    && apt-get -y full-upgrade --no-install-recommends \
    && apt-get install -y libicu67 \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .
COPY --from=builder /bundle /bundle
COPY ./docker/csl/* /usr/bin/

RUN bundle install --without development test && \
    chmod +x /usr/bin/*.sh

EXPOSE 3000

CMD ["/usr/bin/entrypoint.sh"]
