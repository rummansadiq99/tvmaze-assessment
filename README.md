# TV Shows Data Service

A Ruby service that ingests TV show data from TVMaze API, stores it in PostgreSQL, and exposes it through a REST API.

## Features

- Daily ingestion of upcoming TV show releases (next 90 days)
- RESTful API with filtering and pagination
- PostgreSQL database with optimized schema
- Docker-based local development environment

## Quick Start

1. Clone the repository
2. Install Docker and Docker Compose
3. Add this .env file:

`
RACK_ENV=development
DATABASE_URL=postgres://tvshows:tvshows@localhost:5432/tvshows
PORT=4567
`

1. Run the application:
   ```bash
   docker-compose up --build
   ```
2. The API will be available at `http://localhost:4567`

## API Endpoints

### GET /v1/tvshows

Query parameters:
- `date_from`: Start date (YYYY-MM-DD)
- `date_to`: End date (YYYY-MM-DD)
- `distributor`: Filter by distributor
- `country`: Filter by country
- `rating`: Filter by rating
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 20)

Example:
```bash
curl "http://localhost:4567/v1/tvshows?date_from=2024-03-20&date_to=2024-04-20&country=US"
```

## Database Schema

```
tv_shows
  - id (PK)
  - tvmaze_id (unique)
  - name
  - type
  - language
  - status
  - runtime
  - premiered
  - ended
  - rating
  - created_at
  - updated_at

distributors
  - id (PK)
  - name
  - country
  - created_at
  - updated_at

release_dates
  - id (PK)
  - tv_show_id (FK)
  - distributor_id (FK)
  - release_date
  - country
  - created_at
  - updated_at
```

### Indexes

1. `tv_shows(tvmaze_id)` - Unique index for idempotent updates
2. `release_dates(release_date)` - For efficient date range queries
3. `release_dates(tv_show_id, distributor_id)` - For joining and filtering
4. `distributors(name, country)` - For distributor lookups

## Sample Analytical Queries

1. Shows by distributor with release count:
```sql
WITH show_counts AS (
  SELECT distributor_id, COUNT(*) as release_count
  FROM release_dates
  GROUP BY distributor_id
)
SELECT d.name, sc.release_count
FROM distributors d
JOIN show_counts sc ON d.id = sc.distributor_id
ORDER BY sc.release_count DESC;
```

2. Monthly release trends:
```sql
SELECT
  DATE_TRUNC('month', release_date) as month,
  COUNT(*) as releases,
  COUNT(DISTINCT tv_show_id) as unique_shows
FROM release_dates
GROUP BY month
ORDER BY month;
```

3. Top rated shows by country:
```sql
WITH ranked_shows AS (
  SELECT
    ts.name,
    ts.rating,
    rd.country,
    ROW_NUMBER() OVER (PARTITION BY rd.country ORDER BY ts.rating DESC) as rank
  FROM tv_shows ts
  JOIN release_dates rd ON ts.id = rd.tv_show_id
)
SELECT name, rating, country
FROM ranked_shows
WHERE rank <= 5;
```

## Development

### Prerequisites

- Ruby 3.2.2
- PostgreSQL 15
- Docker and Docker Compose

### Local Development

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Set up the database:
   ```bash
   bundle exec rake db:create db:migrate
   ```

3. Run tests:
   ```bash
   bundle exec rspec
   ```

4. Run linter:
   ```bash
   bundle exec rubocop
   ```

## Deployment

The application is designed to be deployed on AWS with the following services:

- ECS (Container Orchestration)
- RDS (PostgreSQL)
- ECR (Container Registry)
- CloudWatch (Logging)
- Route 53 (DNS)
- API Gateway (API Management)
- WAF (Web Application Firewall)

### CI/CD Pipeline

1. GitHub Actions workflow:
   - Run tests
   - Build Docker image
   - Push to ECR
   - Deploy to ECS

2. Deployment process:
   - Blue/Green deployment
   - Automated rollback on failure
   - Zero-downtime updates
