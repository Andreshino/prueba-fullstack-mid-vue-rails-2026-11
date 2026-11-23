# Base image with the same Ruby version as the reference project (ARM64 compatible)
FROM ruby:3.0.7-bullseye

# Use bash as the default shell
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV LANG=en_US.UTF-8

# Debian Bullseye is EOL: point apt to the historical archive
RUN echo "deb [check-valid-until=no] http://archive.debian.org/debian bullseye main" > /etc/apt/sources.list && \
    apt-get -o Acquire::Check-Valid-Until=false update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential \
      git \
      curl \
      libpq-dev \
      postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install gems (system-wide, so the bind mount of /app does not hide them)
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.5.23 --no-document && \
    bundle install --jobs 4 --retry 3

# Copy the application code
COPY . .

EXPOSE 3000

CMD ["bash"]
