# TODO: Create Python 3.9 Base Images
FROM 674907502808.dkr.ecr.us-east-1.amazonaws.com/systems-engineering/amazonlinux2:0.1.1-builder as builder

ARG PYTHON_VERSION=3.9.13

ARG PIP_VERSION=22.0.4
ARG PIPENV_VERSION=2022.3.28
ARG SAFETY_VERSION=1.10.3
ARG WHEEL_VERSION=0.37.1

ENV ARTIFACTORY_REPOSITORY=pypi-services/rs/
ENV NO_GENERATE_CERTIFICATES=1
ENV PIPENV_VENV_IN_PROJECT=1

USER root

# Python build dependencies. See https://github.com/pyenv/pyenv/wiki/Common-build-problems#prerequisites
RUN yum install -y \
    @development \
    bzip2 \
    bzip2-devel \
    findutils \
    git \
    gzip \
    libffi-devel \
    openssl-devel \
    readline-devel \
    sqlite \
    sqlite-devel \
    unzip \
    xz \
    xz-devel \
    zip \
    zlib-devel

ENV PATH="/home/docker/python-${PYTHON_VERSION}/bin:${PATH}"
RUN git clone https://github.com/pyenv/pyenv.git /tmp/pyenv \
    && /tmp/pyenv/plugins/python-build/install.sh \
    && python-build ${PYTHON_VERSION} /home/docker/python-${PYTHON_VERSION} \
    && rm -rf /tmp/pyenv

# Ensure pip, setuptools, & wheel are installed first as they are used for
# optimized installing of other packages
RUN python3 -m pip install --upgrade \
    pip==${PIP_VERSION} \
    # Not pinning this because it has new releases so frequently
    setuptools \
    wheel==${WHEEL_VERSION}
RUN python3 -m pip install \
    pipenv==${PIPENV_VERSION} \
    safety==${SAFETY_VERSION}

##############################
# Production image
##############################
# See for dependency requirements: https://github.com/lampo/maintaining-personalized-experiences-with-machine-learning#prerequisites
FROM 674907502808.dkr.ecr.us-east-1.amazonaws.com/systems-engineering/amazonlinux2:0.1.1

ARG PYTHON_VERSION=3.9.13

ENV ARTIFACTORY_REPOSITORY=pypi-services/rs/
ENV NO_GENERATE_CERTIFICATES=1

# Ensure we're root to install system dependencies
USER root

# Install system dependencies for java
RUN yum install -y java-11-amazon-corretto-headless
# Install CDK CLI
# TODO: Needs to be node 16
COPY bin/setup_14.x /app/setup
RUN bash /app/setup \
    && yum install -y gcc-c++ make nodejs \
    && npm -g i yarn \
    && rm -rf /app/setup \
    && npm install -g aws-cdk@2.12.0
# Copy installed python runtime from builder stage
ENV PATH="/home/docker/python-${PYTHON_VERSION}/bin:${PATH}"
COPY --from=builder /home/docker/python-${PYTHON_VERSION} /home/docker/python-${PYTHON_VERSION}

WORKDIR /app

RUN python -m pip install virtualenv
RUN python -m virtualenv .venv

COPY . /app
RUN chown -R docker:docker /app

RUN /app/.venv/bin/python3 -m pip install -r /app/source/requirements-dev.txt

USER docker

CMD [ "/app/bin/run_deploy.sh" ]