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

RUN curl --silent --location --fail https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.12.933-amd64.deb > /tmp/shiny.deb && \
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

ARG REPO_DIR=${HOME}
ENV REPO_DIR ${REPO_DIR}
WORKDIR ${REPO_DIR}

ENV PATH ${HOME}/.local/bin:${REPO_DIR}/.local/bin:${PATH}


USER root

RUN chown -R ${NB_USER} ${REPO_DIR}

RUN echo "options(repos = c(CRAN='https://mran.microsoft.com/snapshot/2019-04-10'), download.file.method = 'libcurl')" > /etc/R/Rprofile.site

RUN install -o ${NB_USER} -d /var/log/shiny-server && \
install -o ${NB_USER} -d /var/lib/shiny-server && \
install -o ${NB_USER}  /dev/null /var/log/shiny-server.log && \
install -o ${NB_USER}  /dev/null /var/run/shiny-server.pid


#COPY shiny-server.conf /etc/shiny-server/
#install mariadb



#Install java & solr usr/
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
Run apt-get update
RUN apt-get install software-properties-common gnupg -y 
Run apt install dirmngr net-tools nano -y
RUN sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9
RUN echo "deb http://repos.azulsystems.com/debian stable main" | sudo tee /etc/apt/sources.list.d/zulu.list
RUN apt-get update
RUN apt -y install zulu-11
RUN export JAVA_HOME=/usr/lib/jvm/zulu-11/
RUN wget http://www-eu.apache.org/dist/lucene/solr/7.7.2/solr-7.7.2.tgz
RUN tar xzf solr-7.7.2.tgz solr-7.7.2/bin/install_solr_service.sh --strip-components=2
RUN  bash ./install_solr_service.sh solr-7.7.2.tgz
ADD solr-1/logs /opt/logs
ADD solr-1/store /store
ADD solr-1/docker-entrypoint-initdb.d /docker-entrypoint-initdb.d

RUN chown -R jovyan /opt/solr/



####iLCM App + libraries install

RUN mkdir /home/jovyan/iLCM/
COPY iLCM/ /home/jovyan/iLCM
COPY R_tmca_package-master /home/jovyan/


Run apt-get update
Run apt-get install -y --allow-unauthenticated libssl-dev mysql-client libcurl4-openssl-dev libxml2 libgsl-dev gsl-bin libxml2-dev libv8-dev libmariadbclient-dev
Run apt-get install -y libpoppler-cpp-dev

Run apt-get install -y tk

Run R -e "chooseCRANmirror(31,graphics=F);install.packages(c('gsl','slam','Rcpp','topicmodels','tm','igraph','Matrix','readr','digest','htmltools','networkD3','stringdist','glue','jsonlite','plotly','httpuv','mime','shiny','shinythemes','Rtsne','leaps','party','stringi','backports','formattable','RMySQL','RMariaDB','base64enc','yaml','curl','data.table','RcppParallel','quanteda','RCurl'))"
Run R -e "options(scipen=999)"

RUN R -e "devtools::install('/home/jovyan/tmca.util/')"
RUN R -e "devtools::install('/home/jovyan/tmca.cooccurrence/')"
RUN R -e "devtools::install('/home/jovyan/tmca.contextvolatility/')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('lda')"
RUN R -e "devtools::install('/home/jovyan/tmca.unsupervised/')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('shinyFiles')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('bsplus')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('cleanNLP')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('colourpicker')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('d3heatmap')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('future')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('LDAvis')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('readtext')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('rhandsontable')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('shinyAce')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('shinyBS')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('shinycssloaders')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('shinydashboard')"
RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/DT/DT_0.2.tar.gz', repos=NULL, type='source')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('shinyjqui')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('shinyjs')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('shinyWidgets')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('sparkline')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('visNetwork')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('wordcloud2')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('htmlwidgets')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('shinythemes')"
RUN add-apt-repository -y ppa:cran/poppler
RUN apt-get update
RUN sudo apt-get install -y libpoppler-cpp-dev
RUN mkdir /opt/conda/lib/R/library/pdftools/
COPY pdftools/ /opt/conda/lib/R/library/pdftools
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('readtext')"
Run R -e "options(unzip = 'internal');devtools::install_github('nik01010/dashboardthemes')"
Run R -e "options(unzip = 'internal');devtools::install_github('bmschmidt/wordVectors')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('XML')"
Run R -e "options(unzip = 'internal');devtools::install_github('cran/solr')"
Run R -e "options(unzip = 'internal');devtools::install_github('AnalytixWare/ShinySky')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('wordcloud')"
Run R -e "chooseCRANmirror(31,graphics=F);install.packages('sodium')"

#RUN apt-get install libv8-3.14-dev -y 
RUN add-apt-repository ppa:cran/v8
RUN apt-get update
#RUN apt-get install libnode-dev -y

RUN apt-get download libnode-dev -y
RUN dpkg -i libnode-dev 

#RUN R -e "chooseCRANmirror(31,graphics=F);install.packages('V8')"
RUN R -e "options(unzip = 'internal');devtools::install_github('jeroen/v8',force=T)"

#RUN mkdir /opt/conda/lib/R/library/V8/
#COPY V8/ /opt/conda/lib/R/library/V8




RUN chown -R jovyan /home/jovyan/iLCM/




COPY docker-entrypoint.sh /
ENTRYPOINT ["sh", "/docker-entrypoint.sh"]

USER $NB_USER



