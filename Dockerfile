FROM ruby:3.4-slim

# build-essential compiles the ffi/rubyserial native extension; git is needed
# because the gemspec enumerates files with `git ls-files`.
RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends build-essential git \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .
RUN bundle config set --local without "development test" \
 && bundle install

ENTRYPOINT ["bundle", "exec", "dsmr2mqtt"]
