# https://hub.docker.com/r/jupyter/datascience-notebook/tags/
# https://github.com/jupyter/docker-stacks/tree/master/datascience-notebook
FROM jupyter/datascience-notebook:1386e2046833

## Install some more R packages
## Install them by extending the list from https://github.com/jupyter/docker-stacks/blob/master/datascience-notebook/Dockerfile
## in order to prevent them from upgrade/downgrade
#RUN conda install --quiet --yes \
#    'rpy2=2.8*' \
#    'r-base=3.4.1' \
#    'r-irkernel=0.8*' \
#    'r-plyr=1.8*' \
#    'r-devtools=1.13*' \
#    'r-tidyverse=1.1*' \
#    'r-shiny=1.0*' \
#    'r-rmarkdown=1.8*' \
#    'r-forecast=8.2*' \
#    'r-rsqlite=2.0*' \
#    'r-reshape2=1.4*' \
#    'r-nycflights13=0.2*' \
#    'r-caret=6.0*' \
#    'r-rcurl=1.95*' \
#    'r-crayon=1.3*' \
#    'r-randomforest=4.6*' \
#    'r-htmltools=0.3*' \
#    'r-sparklyr=0.7*' \
#    'r-htmlwidgets=1.0*' \
#    'r-hexbin=1.27*' \
#    'r-rjava=0.9*' \
#    # https://cran.r-project.org/web/packages/topicmodels/index.html
#    # r-topicmodels imports r-tm-0.7_5 andn r-tm imports r-nlp-0.1_11
#    'r-topicmodels=0.2*' \
#    'r-lda=1.4*' \
#    && \
#    conda clean -tipsy && \
#    fix-permissions $CONDA_DIR && \
#    fix-permissions /home/$NB_USER

# Install some more python packages
# conda-forge is already added in https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile
RUN conda install --quiet --yes \
    'lxml=4.2.*' \
    'wordcloud=1.5.*' && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Install java for R (for rJava, openNLP, openNLPdata packages)
USER root
RUN apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends \
    gsl-bin \
    libgsl0-dev \
    default-jre \
    default-jdk \
    r-cran-rjava \
    && apt-get clean -qq && \
    rm -rf /var/lib/apt/lists/*
RUN R CMD javareconf
USER $NB_USER


# Install some more R packages
# opennlp requires all r packages to be updated to newer version
RUN conda install --quiet --yes \
    -c bitnik \
    'rpy2' \
    'r-base' \
    'r-irkernel' \
    'r-plyr' \
    'r-devtools' \
    'r-tidyverse' \
    'r-shiny' \
    'r-rmarkdown' \
    'r-forecast' \
    'r-rsqlite' \
    'r-reshape2' \
    'r-nycflights13' \
    'r-caret' \
    'r-rcurl' \
    'r-crayon' \
    'r-randomforest' \
    'r-htmltools' \
    'r-sparklyr' \
    'r-htmlwidgets' \
    'r-hexbin' \
    'r-rjava' \
    # https://cran.r-project.org/web/packages/topicmodels/index.html
    # r-topicmodels imports r-tm-0.7_5 andn r-tm imports r-nlp-0.1_11
    'r-topicmodels=0.2*' \
    'r-lda=1.4*' \
    # install through https://anaconda.org/bitnik/repo
    # https://cran.r-project.org/web/packages/openNLP/index.html
    # OpenNLP imports NLP (≥ 0.1-6.3), openNLPdata (≥ 1.5.3-1), rJava (≥ 0.6-3)
    'r-opennlpdata=1.5.*' \
    'r-opennlp=0.2*' \
    && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN pip install --no-cache-dir nbgitpuller
# avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

USER root 
# Set up locales properly
RUN apt-get -qq update && \
    apt-get -qq install --yes --no-install-recommends locales > /dev/null && \
    apt-get -qq purge && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Use bash as default shell, rather than sh
ENV SHELL /bin/bash

# Set up user
ARG NB_USER
ARG NB_UID
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}


RUN apt-get install gnupg2 -y

RUN wget --quiet -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key |  apt-key add - && \
    DISTRO="bionic" && \
    echo "deb https://deb.nodesource.com/node_10.x $DISTRO main" >> /etc/apt/sources.list.d/nodesource.list && \
    echo "deb-src https://deb.nodesource.com/node_10.x $DISTRO main" >> /etc/apt/sources.list.d/nodesource.list

# Base package installs are not super interesting to users, so hide their outputs
# If install fails for some reason, errors will still be printed
RUN apt-get -qq update && \
    apt-get -qq install --yes --no-install-recommends \
       less \
       nodejs \
       unzip \
       > /dev/null && \
    apt-get -qq purge && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get -qq update && \
    apt-get -qq install --yes \
       libapparmor1 \
       lsb-release \
       psmisc \
       r-base \
       sudo \
       > /dev/null && \
    apt-get -qq purge && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/*
EXPOSE 8888

# Environment variables required for build
ENV APP_BASE /srv
ENV NPM_DIR ${APP_BASE}/npm
ENV NPM_CONFIG_GLOBALCONFIG ${NPM_DIR}/npmrc
ENV CONDA_DIR ${APP_BASE}/conda
ENV NB_PYTHON_PREFIX ${CONDA_DIR}/envs/notebook
ENV KERNEL_PYTHON_PREFIX ${NB_PYTHON_PREFIX}
ENV R_LIBS_USER ${APP_BASE}/rlibs
# Special case PATH
ENV PATH ${NB_PYTHON_PREFIX}/bin:${CONDA_DIR}/bin:${NPM_DIR}/bin:/usr/lib/rstudio-server/bin/:${PATH}
# If scripts required during build are present, copy them

COPY conda/install-miniconda.bash /tmp/install-miniconda.bash

COPY conda/activate-conda.sh /etc/profile.d/activate-conda.sh

COPY conda/environment.py-3.7.frozen.yml /tmp/environment.yml
RUN mkdir -p ${NPM_DIR} && \
chown -R ${NB_USER}:${NB_USER} ${NPM_DIR}

USER ${NB_USER}
RUN npm config --global set prefix ${NPM_DIR}

USER root
RUN bash /tmp/install-miniconda.bash && \
rm /tmp/install-miniconda.bash /tmp/environment.yml

RUN mkdir -p ${R_LIBS_USER} && \
chown -R ${NB_USER}:${NB_USER} ${R_LIBS_USER}

RUN curl --silent --location --fail https://download2.rstudio.org/rstudio-server-1.1.419-amd64.deb > /tmp/rstudio.deb && \
echo '24cd11f0405d8372b4168fc9956e0386 /tmp/rstudio.deb' | md5sum -c - && \
dpkg -i /tmp/rstudio.deb && \
rm /tmp/rstudio.deb

RUN curl --silent --location --fail https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.7.907-amd64.deb > /tmp/shiny.deb && \
echo '78371a8361ba0e7fec44edd2b8e425ac /tmp/shiny.deb' | md5sum -c - && \
dpkg -i /tmp/shiny.deb && \
rm /tmp/shiny.deb

RUN sed -i -e '/^R_LIBS_USER=/s/^/#/' /etc/R/Renviron && \
echo "R_LIBS_USER=${R_LIBS_USER}" >> /etc/R/Renviron

USER ${NB_USER}
RUN pip install --no-cache-dir https://github.com/jupyterhub/jupyter-server-proxy/archive/7ac0125.zip && \
pip install --no-cache-dir jupyter-rsession-proxy==1.0b6 && \
jupyter serverextension enable jupyter_server_proxy --sys-prefix && \
jupyter nbextension install --py jupyter_server_proxy --sys-prefix && \
jupyter nbextension enable --py jupyter_server_proxy --sys-prefix

RUN R --quiet -e "install.packages('devtools', repos='https://mran.microsoft.com/snapshot/2018-02-01', method='libcurl')" && \
R --quiet -e "devtools::install_github('IRkernel/IRkernel', ref='0.8.11')" && \
R --quiet -e "IRkernel::installspec(prefix='$NB_PYTHON_PREFIX')"

RUN R --quiet -e "install.packages('shiny', repos='https://mran.microsoft.com/snapshot/2019-04-10', method='libcurl')"



# Allow target path repo is cloned to be configurable
ARG REPO_DIR=${HOME}
ENV REPO_DIR ${REPO_DIR}
WORKDIR ${REPO_DIR}

# We want to allow two things:
#   1. If there's a .local/bin directory in the repo, things there
#      should automatically be in path
#   2. postBuild and users should be able to install things into ~/.local/bin
#      and have them be automatically in path
#
# The XDG standard suggests ~/.local/bin as the path for local user-specific
# installs. See https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
ENV PATH ${HOME}/.local/bin:${REPO_DIR}/.local/bin:${PATH}

# Copy and chown stuff. This doubles the size of the repo, because
# you can't actually copy as USER, only as root! Thanks, Docker!
USER root
COPY src/ ${REPO_DIR}
RUN chown -R ${NB_USER}:${NB_USER} ${REPO_DIR}

# Run assemble scripts! These will actually build the specification
# in the repository into the image.
RUN echo "options(repos = c(CRAN='https://mran.microsoft.com/snapshot/2019-04-10'), download.file.method = 'libcurl')" > /etc/R/Rprofile.site

RUN install -o ${NB_USER} -g ${NB_USER} -d /var/log/shiny-server && \
install -o ${NB_USER} -g ${NB_USER} -d /var/lib/shiny-server && \
install -o ${NB_USER} -g ${NB_USER} /dev/null /var/log/shiny-server.log && \
install -o ${NB_USER} -g ${NB_USER} /dev/null /var/run/shiny-server.pid

USER ${NB_USER}
RUN Rscript install.R


# Container image Labels!
# Put these at the end, since we don't want to rebuild everything
# when these change! Did I mention I hate Dockerfile cache semantics?

LABEL repo2docker.version="0.9.0"
LABEL repo2docker.repo="https://github.com/binder-examples/r"
LABEL repo2docker.ref="None"

# We always want containers to run as non-root
USER ${NB_USER}

# Add start script
# Add entrypoint
COPY /repo2docker-entrypoint /usr/local/bin/repo2docker-entrypoint
ENTRYPOINT ["/usr/local/bin/repo2docker-entrypoint"]

# Specify the default command to run
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
