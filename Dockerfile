FROM ruby:3.2.2-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install gems
COPY Gemfile* ./
RUN bundle install

# Copy application code
COPY . .

# Expose port
EXPOSE 4567

# Start the application
CMD ["bundle", "exec", "ruby", "app.rb"]
