escape_quotes<-function(data){
  for(column in 1:dim(data)[2]){
    data[,column]<-stringr::str_replace_all(string =  data[,column],pattern = "[^\\\\]'",replacement = "\\\\'")
   # data[,column]<-stringr::str_replace_all(string =  data[,column],pattern = '[^\\\\]"',replacement = '\\\\"')
  }
  return(data)
}