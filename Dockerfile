ARG FROM=python:3.10-bullseye

####################
# Define a base system image and set common environment variables
####################
FROM $FROM AS base

ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    PIP_TIMEOUT=100 \
    \
    # poetry
    # https://python-poetry.org/docs/configuration/#using-environment-variables
    POETRY_VERSION=1.2.0 \
    # make poetry install to this location
    POETRY_HOME="/opt/poetry" \
    # make poetry create the virtual environment in the project's root
    # it gets named `.venv`
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    # no interaction with shell
    POETRY_NO_INTERACTION=1 \
    \
    # paths
    # this is where our requirements + virtual environment will live
    VENV_PATH="/opt/venv" \
    APP_PATH="/app" \
    PATH=${PATH}:/opt/poetry/bin

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        # deps for installing poetry
        ca-certificates \
        curl \
        # deps for building python deps
        gcc g++ libc-dev make \
        # deps for postgresql
        libpq-dev \
    && rm -rf /var/lib/apt/lists

RUN curl -sSL https://install.python-poetry.org | python3 -
WORKDIR ${APP_PATH}
COPY pyproject.toml ${APP_PATH}
COPY poetry.lock ${APP_PATH}
RUN poetry install --only main --no-root
COPY . ${APP_PATH}
RUN poetry install --only main
CMD ["poetry", "run", "python3", "main.py"]
