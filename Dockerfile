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
USER $NB_USER