# https://hub.docker.com/r/jupyter/datascience-notebook/tags/
# https://github.com/jupyter/docker-stacks/tree/master/datascience-notebook

jupyter/datascience-notebook:7a0c7325e470


# Install some more python packages
# conda-forge is already added in https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile
RUN conda install --quiet --yes \
    'lxml=4.2.*' \
    'wordcloud=1.5.*' && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER



USER $NB_USER

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
COPY fifer/ /opt/conda/lib/R/library/fifer
COPY Hmisc/ /opt/conda/lib/R/library/Hmisc


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
    

#ARG REPO_DIR=${HOME}
#ENV REPO_DIR ${REPO_DIR}
WORKDIR ${HOME}
ENV PATH ${HOME}/.local/bin:${HOME}/.local/bin:${PATH}


USER root
RUN chown -R ${NB_USER} ${HOME}
RUN echo "options(repos = c(CRAN='https://mran.microsoft.com/snapshot/2019-04-10'), download.file.method = 'libcurl')" > /etc/R/Rprofile.site && \
    install -o ${NB_USER} -d /var/log/shiny-server && \
    install -o ${NB_USER} -d /var/lib/shiny-server && \
    install -o ${NB_USER}  /dev/null /var/log/shiny-server.log && \
    install -o ${NB_USER}  /dev/null /var/run/shiny-server.pid


#install r libraries

Run apt-get update && \
   R -e  "chooseCRANmirror(31,graphics=F);install.packages(c('gsl','slam','Rcpp','topicmodels','tm','igraph','Matrix','readr','digest','htmltools','networkD3','stringdist','glue','jsonlite','plotly','httpuv','mime','shiny','shinythemes','Rtsne','leaps','party','stringi','backports','formattable','RMySQL','base64enc','yaml','curl','data.table','RcppParallel','quanteda','RCurl'))" $$ \
    R -e "options(scipen=999)" && \
    conda install gxx_linux-64 && \
    R -e "chooseCRANmirror(31,graphics=F);install.packages('testthat')" && \
    R -e "chooseCRANmirror(31,graphics=F);devtools::install('/home/jovyan/tmca.util/');devtools::install('/home/jovyan/tmca.cooccurrence/');devtools::install('/home/jovyan/tmca.contextvolatility/');install.packages('lda');devtools::install('/home/jovyan/tmca.unsupervised/');install.packages('shinyFiles');install.packages('bsplus');install.packages('cleanNLP');install.packages('colourpicker');install.packages('d3heatmap');install.packages('solrium');install.packages('LDAvis');install.packages('readtext');install.packages('rhandsontable');install.packages('shinyAce');install.packages('shinyBS');install.packages('shinycssloaders');install.packages('shinydashboard');install.packages('https://cran.r-project.org/src/contrib/Archive/DT/DT_0.2.tar.gz', repos=NULL, type='source');install.packages('shinyjqui');install.packages('shinyjs');install.packages('shinyWidgets');install.packages('sparkline');install.packages('visNetwork');install.packages('wordcloud2');install.packages('htmlwidgets');install.packages('shinythemes');install.packages('https://cran.r-project.org/src/contrib/Archive/future/future_1.8.1.tar.gz', repos=NULL, type='source')" && \
    R -e "chooseCRANmirror(31,graphics=F);install.packages('readtext')" && \
    R -e "options(unzip = 'internal');devtools::install_github('nik01010/dashboardthemes')" && \
    R -e "options(unzip = 'internal');devtools::install_github('bmschmidt/wordVectors')" && \
    R -e "chooseCRANmirror(31,graphics=F);install.packages('XML')" && \
    R -e "options(unzip = 'internal');devtools::install_github('cran/solr')" && \
    R -e "options(unzip = 'internal');devtools::install_github('AnalytixWare/ShinySky')" && \
    R -e "chooseCRANmirror(31,graphics=F);install.packages('wordcloud')" && \
    R -e "chooseCRANmirror(31,graphics=F);install.packages('sodium')" && \
    export TAR="/bin/tar" && \
    apt autoremove -y && \
    apt install -y r-cran-curl r-cran-knitr r-cran-testthat r-cran-jsonlite r-cran-jsonlite r-cran-httpuv && \
    conda install -c conda-forge libv8  && \
    R -e "chooseCRANmirror(31,graphics=F);install.packages('V8')"  && \
    chown -R jovyan /home/jovyan/iLCM/  && \
    R -e "chooseCRANmirror(31,graphics=F);install.packages('Matrix');install.packages('igraph');install.packages('networkD3');install.packages('slam');install.packages('tm');install.packages('diffr');options(unzip = 'internal');devtools::install_github('ThomasSiegmund/shinyTypeahead')"  && \
    conda update -y conda  && \
    conda install -y spacy  && \
    python -m spacy download de  && \
    python -m spacy download en  && \
    chown -R jovyan /opt/conda/  && \
    R -e "chooseCRANmirror(31,graphics=F);install.packages('shinyalert')"  && \
    R -e "chooseCRANmirror(31,graphics=F);install.packages('globals');install.packages('listenv');install.packages('https://cran.r-project.org/src/contrib/Archive/future/future_1.8.1.tar.gz', repos=NULL, type='source')" && \
    R -e "chooseCRANmirror(31,graphics=F);install.packages('randomcoloR');install.packages('acepack');install.packages('Formula');options(unzip = 'internal');devtools::install_github('cran/latticeExtra');install.packages('foreign');install.packages('htmlTable');install.packages('fields');install.packages('plotrix');install.packages('randomForestSRC');install.packages('tidytext');install.packages('textreuse');devtools::install_github('ramnathv/rChartsCalmap');devtools::install_github('lchiffon/wordcloud2');devtools::install_github('ijlyttle/bsplus')"






#configure mariadb

RUN test -d /var/run/mariadb || mkdir /var/run/mariadb; \
    chmod 0777 /var/run/mariadb; \
    /usr/bin/mysqld_safe --basedir=/usr & \
    sleep 10s && \
    mysql --user=root --password=ilcm < /tmp/init_iLCM.sql && \
    mysqladmin shutdown --password=ilcm

RUN chmod -R 777 /var/lib/mysql && \
    chmod -R 777 /var/log/mysql && \
    chmod -R 777 /var/run/mysqld && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    apt-get clean -y &&\
    rm -r /home/jovyan/solr && \
    rm -r /home/jovyan/tmca.classify && \
    rm -r /home/jovyan/tmca.contextvolatility && \
    rm -r /home/jovyan/tmca.cooccurrence && \
    rm -r /home/jovyan/oldSources && \
    rm -r /home/jovyan/tmca.experiments && \
    rm -r /home/jovyan/db && \
    rm -r /home/jovyan/tmca.iLCMProjectDocumentation && \
    rm -r /home/jovyan/tmca.supervised && \
    rm -r /home/jovyan/tmca.unsupervised && \
    rm -r /home/jovyan/tmca.util && \
    rm  /home/jovyan/docker-compose.yml && \
    rm  /home/jovyan/iLCM-source_reader_system.Rproj && \
    rm  /home/jovyan/install_solr_service.sh && \
    rm  /home/jovyan/R_tmca_package.Rproj && \
    rm  /home/jovyan/read_conll_test.R && \
    rm  /home/jovyan/runDockerZookeeperSolrMariaDB.R && \
    rm  /home/jovyan/small_dtm.rdata && \
    rm  /home/jovyan/solr-7.7.2.tgz && \
    rm  /home/jovyan/tdt_test.R && \
    rm  /home/jovyan/tmca-master.Rproj && \
    rm  /home/jovyan/ClassTest.R && \
    rm  /home/jovyan/windowsSetupAndreas.R






RUN mkdir /home/jovyan/mysql/ && \
    cp -r /var/lib/mysql/* /home/jovyan/mysql/ && \
    chown -R jovyan /home/jovyan/mysql  && \
    mkdir /home/jovyan/solr/ && \
    chown -R jovyan /home/jovyan/solr

COPY my.cnf /etc/mysql/my.cnf 

RUN conda remove julia -y

RUN conda clean -a -y

COPY docker-entrypoint.sh /
ENTRYPOINT ["sh", "/docker-entrypoint.sh"]

USER $NB_USER


