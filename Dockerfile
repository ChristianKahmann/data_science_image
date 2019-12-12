FROM jupyter/datascience-notebook
# install nbrsessionproxy extension
RUN conda install -yq -c conda-forge nbrsessionproxy && \
    conda clean -tipsy

# install rstudio-server
USER root
RUN apt update
RUN apt-get update && \
    curl --silent -L --fail https://download1.rstudio.org/desktop/bionic/amd64/rstudio-1.2.5001-amd64.deb > /tmp/rstudio.deb && \
    echo '24cd11f0405d8372b4168fc9956e0386 /tmp/rstudio.deb' | md5sum -c - && \
    apt-get install -y /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb && \
    apt-get clean
    
ENV PATH=$PATH:/usr/lib/rstudio-server/bin
USER $NB_USER