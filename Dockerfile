FROM jupyter/datascience-notebook
# install nbrsessionproxy extension
RUN conda install -yq -c conda-forge nbrsessionproxy && \
    conda clean -tipsy

# install rstudio-server
USER root
RUN apt-get update && \
    curl --silent -L --fail https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.2.5019-amd64.deb > /tmp/rstudio.deb && \
    apt-get install -y /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb && \
    apt-get clean
    
ENV PATH=$PATH:/usr/lib/rstudio-server/bin



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
#COPY src/ ${REPO_DIR}
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


USER $NB_USER