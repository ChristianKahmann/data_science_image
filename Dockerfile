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

RUN conda install -yq -c conda-forge nbrsessionproxy && \
    conda clean -tipsy 
    
    
USER root
#Copy Data
USER root
RUN mkdir /home/jovyan/iLCM/
COPY iLCM/ /home/jovyan/iLCM
COPY R_tmca_package-master /home/jovyan/
COPY pdftools/ /opt/conda/lib/R/library/pdftools
COPY .profile /home/jovyan/.profile
#RUN rm /etc/mysql/my.cnf  später erst möglich
#COPY my.cnf /etc/mysql/my.cnf
ADD solr-1/logs /opt/logs
ADD solr-1/store /store
ADD solr-1/docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
ADD init_iLCM.sql /tmp/init_iLCM.sql
COPY RMariaDB/ /opt/conda/lib/R/library/RMariaDB


#install libraries, solr, mariadb
RUN apt-get update && \
    apt-get install -y --allow-unauthenticated libssl-dev mysql-client libcurl4-openssl-dev libxml2 libgsl-dev gsl-bin libxml2-dev libv8-dev libmariadbclient-dev && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt install dirmngr net-tools nano -y && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9 && \
    echo "deb http://repos.azulsystems.com/debian stable main" | sudo tee /etc/apt/sources.list.d/zulu.list && \
    apt-get update && \
    apt -y install zulu-11 && \
    export JAVA_HOME=/usr/lib/jvm/zulu-11/ && \
    wget http://www-eu.apache.org/dist/lucene/solr/7.7.2/solr-7.7.2.tgz && \
    tar xzf solr-7.7.2.tgz solr-7.7.2/bin/install_solr_service.sh --strip-components=2 && \
    bash ./install_solr_service.sh solr-7.7.2.tgz && \
    chown -R jovyan /opt/solr/ && \
    apt-get install -y tk && \
    apt-get install -y software-properties-common && \
    apt-get update && \
    add-apt-repository -y ppa:cran/poppler && \
    apt-get update && \
    apt-get install -y libpoppler-cpp-dev && \
    apt-get update && \
    apt-get install gnupg -y  && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 && \
    add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://ftp.hosteurope.de/mirror/mariadb.org/repo/10.3/ubuntu bionic main' && \
    apt-get update
RUN  ["/bin/bash", "-c", "debconf-set-selections <<< 'mariadb-server-10.3 mysql-server/root_password password ilcm'"] 
RUN  ["/bin/bash", "-c", "debconf-set-selections <<< 'mariadb-server-10.3 mysql-server/root_password_again password ilcm'"] 
RUN DEBIAN_FRONTEND=noninteractive apt-get install --allow-unauthenticated -y net-tools mariadb-server libmariadbclient18 nano dirmngr

# install rstudio-server & shiny server
USER root
RUN apt-get update && \
    curl --silent -L --fail https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.2.5019-amd64.deb > /tmp/rstudio.deb && \
    apt-get install -y /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb && \
    apt-get clean &&  \
    curl --silent --location --fail https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.12.933-amd64.deb > /tmp/shiny.deb && \
    dpkg -i /tmp/shiny.deb && \
    rm /tmp/shiny.deb && \
    sed -i -e '/^R_LIBS_USER=/s/^/#/' /etc/R/Renviron && \
    echo "R_LIBS_USER=${R_LIBS_USER}" >> /etc/R/Renviron
#RUN apt-get install systemd -y    
#ENV PATH=$PATH:/usr/lib/rstudio-server/bin

# install jupyter extensiosn for rstudio and shiny server
USER ${NB_USER}
RUN pip install --no-cache-dir https://github.com/jupyterhub/jupyter-server-proxy/archive/7ac0125.zip && \
    pip install --no-cache-dir jupyter-rsession-proxy==1.0b6 && \
    jupyter serverextension enable jupyter_server_proxy --sys-prefix && \
    jupyter nbextension install --py jupyter_server_proxy --sys-prefix && \
    jupyter nbextension enable --py jupyter_server_proxy --sys-prefix && \
    R --quiet -e "install.packages('devtools', repos='https://mran.microsoft.com/snapshot/2018-02-01', method='libcurl')" && \
    R --quiet -e "devtools::install_github('IRkernel/IRkernel', ref='0.8.11')" && \
    R --quiet -e "IRkernel::installspec(prefix='$NB_PYTHON_PREFIX')" && \
    R --quiet -e "install.packages('shiny', repos='https://mran.microsoft.com/snapshot/2019-04-10', method='libcurl')"
    
    
RUN conda clean -a

USER $NB_USER

