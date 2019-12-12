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

#RUN R -e "install.packages('shiny')"

RUN apt-get install -y libcurl4-openssl-dev 
RUN apt-get install -y libxml2-dev
RUN apt-get install -y gdebi-core
RUN wget http://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.3.0.403-amd64.deb
RUN gdebi shiny-server-1.3.0.403-amd64.deb
RUN chmod -R 777 /srv

USER $NB_USER