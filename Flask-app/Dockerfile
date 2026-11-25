FROM python:3.12-slim

WORKDIR /app

# Patch OS packages
RUN apt-get update && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

# Upgrade built-in Python packaging tools to clear base image Python CVEs
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Copy pyproject.toml, generate poetry.lock on the fly, install dependencies, and remove Poetry
COPY pyproject.toml ./
RUN pip install --no-cache-dir poetry && \
    poetry config virtualenvs.create false && \
    poetry lock && \
    poetry install --no-interaction --no-ansi --no-root --only main && \
    pip uninstall -y poetry && \
    rm -rf /root/.cache

# Copy application code
COPY . .

# Run as non-root user
RUN useradd --create-home appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 5000

CMD ["python", "/app/app-flask/app.py"]


# docker build -t flask-kubernetes .