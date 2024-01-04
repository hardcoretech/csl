# Stage 1: Build the Rails app
FROM ruby:2.6.10-bullseye as builder

# Set environment variables
ENV LANG=C.UTF-8 \
    RAILS_ENV=production \
    BUNDLE_JOBS=4

WORKDIR /repo

# copy the Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN gem update --system 3.2.3 && \
    gem install bundler -v 2.4.22 && \
    bundle update --bundler && \
    bundle config set --local without 'development test' && \
    bundle install --no-color

# Stage 2: Create a smaller image with Debian Bullseye
FROM ruby:2.6.10-slim-bullseye AS final

# Set environment variables
ENV LANG=C.UTF-8 \
    RAILS_ENV=production

    # Install security updates
RUN apt-get update  \
    && apt-get -y full-upgrade --no-install-recommends \
    \
    # Install dependencies for building ruby gems
    && apt-get install -y libicu67=67.1-7 --no-install-recommends \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY ./docker/csl/*.sh /usr/bin/

RUN gem update --system 3.2.3 && \
    chmod +x /usr/bin/*.sh

EXPOSE 3000

CMD ["/usr/bin/entrypoint.sh"]
