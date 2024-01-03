########################################
# Backend Builder stage
########################################
FROM python:3.11-bookworm AS builder
    # python
ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    # pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    # do not ask any interactive question
    POETRY_NO_INTERACTION=1

WORKDIR /repo

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

COPY pyproject.toml poetry.lock ./

    # Upgrade pip and install poetry
RUN pip install --no-cache-dir pip==23.3.1 poetry==1.7.1 && \
    # export poetry configuration file to requirements.txt
    poetry export --without-hashes -o /repo/requirements.txt && \
    # Build python packages with wheel format
    pip wheel -r /repo/requirements.txt --wheel-dir=/repo/wheels && \
    # Build python packages with sdist format for final stage
    find /repo/wheels/ -name '*.whl' > /repo/requirements-wheel.txt

########################################
# Backend Final stage
########################################
FROM python:3.11-slim-bookworm

ENV WORKDIR=/app

WORKDIR ${WORKDIR}

COPY --from=builder /repo/ /repo/
COPY . ${WORKDIR}/
COPY ./entrypoint.sh /usr/local/bin/
COPY ./wait-for-it.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/*.sh


RUN set -ex \
    && apt-get update \
    # Security updates
    && apt-get full-upgrade -y \
    && apt-get install -y --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
    \
    # create a non-root user
    && useradd --system --no-create-home -u 1000 appuser \
    \
    # Install only required dependencies
    && pip install --no-cache-dir --no-index \
    --find-links=/repo/wheels \
    -r /repo/requirements-wheel.txt

# Run as non-root user to avoid security concern
USER appuser

CMD ["/usr/local/bin/entrypoint.sh"]
