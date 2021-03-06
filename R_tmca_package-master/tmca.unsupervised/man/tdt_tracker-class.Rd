% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/topic_cluster_tdt.R
\docType{class}
\name{tdt_tracker-class}
\alias{tdt_tracker-class}
\alias{tdt_tracker}
\title{An S4 class to represent a Topic Detection and Tracking Object.}
\description{
An S4 class to represent a Topic Detection and Tracking Object.
}
\section{Slots}{

\describe{
\item{\code{history}}{A document-term-matrix (dgCMatrix) containing a set of already processed documents.}

\item{\code{document_frequency}}{A vector containing the information of the document frequencies of all allready seen words. This vector is sychronized by the history and new data batches.}

\item{\code{clusters}}{A vector holding information on the cluster assignment of the processed documents.}

\item{\code{is}}{A vector holding the exernal id information of the processed documents.}
}}

