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
    
RUN apt-get install systemd -y    
ENV PATH=$PATH:/usr/lib/rstudio-server/bin

#RUN curl --silent --location --fail https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.12.933-amd64.deb > /tmp/shiny.deb && \
#dpkg -i /tmp/shiny.deb && \
#rm /tmp/shiny.deb

#RUN sed -i -e '/^R_LIBS_USER=/s/^/#/' /etc/R/Renviron && \
#echo "R_LIBS_USER=${R_LIBS_USER}" >> /etc/R/Renviron

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

ARG REPO_DIR=${HOME}
ENV REPO_DIR ${REPO_DIR}
WORKDIR ${REPO_DIR}

ENV PATH ${HOME}/.local/bin:${REPO_DIR}/.local/bin:${PATH}


USER root



RUN echo "options(repos = c(CRAN='https://mran.microsoft.com/snapshot/2019-04-10'), download.file.method = 'libcurl')" > /etc/R/Rprofile.site

#COPY 051-movie-explorer/ /home/jovyan/beispielsapp/

#COPY shiny-server.conf /etc/shiny-server/

USER $NB_USER
