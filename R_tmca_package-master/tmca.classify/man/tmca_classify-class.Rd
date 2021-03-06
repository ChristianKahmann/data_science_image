% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/classification.R
\docType{class}
\name{tmca_classify-class}
\alias{tmca_classify-class}
\alias{tmca_classify}
\title{TMCA classification}
\value{
tmca classification object to run classification / active learning
}
\description{
This class wraps functions around LiblineaR to conduct active
learning and standard text classification in a social science
scenario, especially to  allow for accurate predictions of
category proportions and their changes in large data sets.
At the moment, only binary classification is supported.
}
\details{
1. The object is initialized given a corpus and a factor
containing category information. A corpus is simply
a character vector containing all documents. The labels
factor has to be of the same length as the corpus. Its levels
represent the categories (e.g. "Positive" and "Negative").
Unknown labels need to be encoded as NA values in the factor.

To use the class in an experiment setting, e.g. to evaluate
active learning performance (and different pre-processing or
query selection strategies), an object can be initialized
further by a factor of gold labels considered as truth values
for document categories in subsequent steps.

2. The initialization invokes ngram-features extraction. When
useful, additional LDA features can be extracted.

3. An inital training set is sampled and labelled. In the
standard setting, a human annotator is asked for query labels.
In the experiment setting, labels are taken from the gold
labels.

4. Active learning is performed an stops at a defined
stability threshold criterion. Again, in the
standard setting, a human annotator is asked for query labels.
In the experiment setting, labels are taken from the gold
labels.

For the usual evaluation scenario it makes sense to set the entire
corpus also as validation corpus instead of using hold out data.
This allows the active learning process to learn from all data.
For this, one can set `set_validation_AL_corpus()` before starting
active learning experiments.
}
\section{Fields}{

\describe{
\item{\code{corpus}}{character vector containing documents.}

\item{\code{labels}}{factor (optional) may contain previously made annotation.
Is supposed to be a factor with two levels. Unlabeled instances need
to be encoded as NA values.}

\item{\code{gold_labels}}{factor  (optional) may contain previously made annotation.
Is supposed to be a factor with two levels. Unlabeled instances need
to be encoded as NA values.}

\item{\code{iteration}}{numeric counts iterations of active learning.}

\item{\code{progress}}{data.frame keeps record of learning progress.}

\item{\code{progress_examples}}{list keeps record of newly learned examples (ids).}

\item{\code{progress_validation}}{data.frame. keeps record of learning progress on a validation set}

\item{\code{stop_words}}{character vector for words to remove during ngram feature extraction.
Default value is a list for English stopwords.}

\item{\code{negation_words}}{two-column data.frame for pairs of strings and replacements to better
capture negation (e.g. containing aren't | are not). Default value is a list for English
negation terms.}

\item{\code{language}}{character language code to select correct stopword lists and stemmers. Default = "en"}

\item{\code{dfm_ngram}}{Matrix extracted ngram-features.}

\item{\code{dfm_lda}}{Matrix extracted LDA features.}

\item{\code{model_svm}}{list SVM model from currently labelled set.}

\item{\code{model_lda}}{LDA_Gibbs model from a given reference corpus.}

\item{\code{lda_most_frequent_term}}{character for internal use.}

\item{\code{validation_corpus}}{character validation (hold out) set.}

\item{\code{validation_labels}}{factor validation (hold out) labels.}

\item{\code{validation_dfm_ngram}}{Matrix validation (hold out) ngram features.}

\item{\code{validation_dfm_lda}}{Matrix validation (hold out) LDA features.}
}}

\section{Methods}{

\describe{
\item{\code{active_learning(batch_size = 10L, max_iterations = 200, tune_C = FALSE,
  cross = NULL, stop_threshold = 0.99, stop_window = 3, type = 7,
  verbose = TRUE, positive_class = NULL)}}{Active learning for classification. If gold labels are present,
experiment mode is conducted. Otherwise, the user oracle is asked
to decide on selected examples.}

\item{\code{classify(dfm_target = .self$get_dfm(), tune_C = FALSE, cross = NULL,
  type = 7, verbose = TRUE, positive_class = NULL)}}{Perform classification using the currently labelled instances as training data.
Returns the classifier decisions as vector. If no target feature matrix (dfm_target)
is given, the dfm of the current classification object is assumed as default.}

\item{\code{create_initial_trainingset(n = 100)}}{Creates an initial training set for active learning. If gold labels
are present, an experiment setting is assumed and n true labels are
sampled from the gold labels. If no gold labels are present, a (human)
annotator is asked to judge n samples.}

\item{\code{cross_validation(cv_dfm, cv_labels, n_folds = 10, cost = 1, type = 7,
  positive_class = NULL)}}{N-fold cross validation for classification. Classifcation data is split into n folds.
Training is conducted on n-1 folds and the resulting model is evaluated on the remaining fold.
The process is repeated n_fold times with changing test folds. Mean evaluation measures
are returned as result.}

\item{\code{extract_features_lda(lda_corpus, TRAIN = T, K = 50, n_repeat = 20,
  iter = 500, verbose = 25)}}{Create K latent semantic features from an LDA topic model (Phan et al. 2011).}

\item{\code{extract_features_ngram(text_corpus = .self$corpus, TRAIN = TRUE,
  minimum_frequency = 2, removeSW = F, bigrams = T, binary_dfm = FALSE,
  feature_dictionary = colnames(.self$dfm_ngram))}}{Extracts ngrams from the corpus. For using parallelization register
a suitable parallel backend.
# For parallelization: register backends
# if(.Platform$OS.type == "unix") {
#   require(doMC)
#   registerDoMC(8)
# } else {
#   require(doParallel)
#   workers <- makeCluster(4, type="SOCK")
#   registerDoParallel(workers)
# }}

\item{\code{extract_ngrams(text, useStemming = TRUE, useBigrams = TRUE,
  removeSW = FALSE, lower = TRUE, replaceNumbers = TRUE)}}{Extracts ngram word features by regex tokenizer. Preprocessing:
negation word normalization, stemming, bigrams,
stop word removal, lower case reduction, number replacement. Set
language slot to use correct stemmer and stop word/negation lists.}

\item{\code{get_dfm(validation = FALSE)}}{Retrieves the current feature matrix. Combines ngram-features
with LDA features, if both are present.}

\item{\code{initialize(corpus, labels = NULL, iteration = 1, gold_labels = factor(),
  stop_words = NULL, negation_words = NULL, language = "en",
  minimum_frequency = 2)}}{Creation of classification object from corpus.
Corpus is supposed to be a character vector.
More options for feature extraction are possible.}

\item{\code{optimize_C(trainingDTM, trainingLabels, plot_graph = F)}}{C-parameter optimization by testing different values
(0.003, 0.01, 0.03, 0.1, 0.3, 1, 3 , 10, 30, 100).}

\item{\code{plot_progress()}}{Plot the progress of active learning. If a validation set is given
evaluation metrics on this validation set are plotted.
For the usual evaluation scenario it makes sense to set the entire
corpus also as validation corpus instead of using hold out data.
This allows the active learning process to learn from all data.}

\item{\code{reset_active_learning(new_gold_labels = factor())}}{Reset labels, progress records and iteration count.
This is useful for AL experimentation, when feature
generation is costly.}

\item{\code{select_queries(model, u_dfm, u_labels_idx, batch_size, verbose = 1,
  strategy = "LC")}}{Select queries for the (human) oracle by different strategies.}

\item{\code{set_validation_AL_corpus()}}{Sets validation hold out set to the same data as the
primary classification set. This is for evaluation of
progress of active learning.}

\item{\code{set_validation_holdout_corpus(v_corpus, v_labels)}}{Sets validation hold out set to the given v_corpus and
v_labels. This is not advised when using active learning.
Since good examples cannot be learned from the hold
out set, classification performance will be drastically
lowered.}

\item{\code{stop_criterion_matches(v, window = 2, threshold = 0.99)}}{Stopping criterion for active learning: Stability (see Bloodgood; Vijay-Shanker 2009)}
}}

\examples{
my_corpus <- c("It's brilliant", "Me no likey.", "It was brilliant.", "Soo bad.", "It was great", "I love it!!!", "Not good!")
my_labels <- factor(rep(NA, length(my_corpus)), levels = c("Positive", "Negative"))
my_classification <- tmca_classify(corpus = my_corpus, labels = my_labels)
my_classification$create_initial_trainingset(n = 4)
my_classification$active_learning(batch_size = 1)
}
