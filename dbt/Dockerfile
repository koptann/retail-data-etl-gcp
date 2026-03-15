FROM ghcr.io/dbt-labs/dbt-bigquery:1.9.0

COPY . /app
WORKDIR /app

ENV DBT_PROJECT_DIR=/app
ENV DBT_PROFILES_DIR=/app

RUN dbt deps

ENTRYPOINT ["dbt"]
CMD ["run", "--project-dir", "/app", "--profiles-dir", "/app"]

