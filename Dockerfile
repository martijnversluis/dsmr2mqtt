FROM ruby:3.4-slim

# build-essential is needed to compile the ffi/rubyserial native extension.
RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends build-essential \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .
RUN bundle config set --local without "development test" \
 && bundle install

ENTRYPOINT ["bundle", "exec", "dsmr2mqtt"]
