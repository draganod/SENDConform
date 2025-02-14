###############################################################################
# FILE: Functions.R
# DESC: Functions called during the data conversion from XPT to CSV
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO: shortenIRI() to replace use of IRItoPrefix
###############################################################################

#' Encode Column
#' Create URL Encoded column for use in valid IRIs
#'
#' @param data Name of dataframe
#' @param col  Name of column to encode
#' @param removeCol  TRUE/FALSE(default)  Remove the column after it the
#'    encoded value is created. The orginal value is not used in the graph data
#'                   
#'  as.character conversion needed for URLencode that was not needed for
#'   curlEscape.
#'  Leaving in the FOR loop example in case need use of is.na
#' @return Encoded column in a new column with _en suffix
#'
#' @examples
#' encodeCol(data=dm, col=ethnic)
#' encodeCol(data=dm, col=refInt_im, removeCol=TRUE)

#' Previous encoding was: 
#' # mutate( !!encoded := curlEscape(data[,col]))
#' # mutate( !!encoded := URLencode(data[,col])) 
encodeCol<-function(data, col, removeCol=FALSE)
{
  encoded <- paste0(col, "_en")
  for (i in 1:nrow(data))
  {
    if (!is.na(data[i,col])){
      # data[i,encoded] <- URLencode(paste(data[i,col])) # Percent encoded
      # data[i,encoded] <- gsub(" ", "&#x20;", data[i,col]) # HTML hex encoded
      #TW: Was ". |:   
      data[i,encoded] <- gsub(" |:", "_", data[i,col]) # replace with underbar
    }
  }
  # Remove the original column if it is only used to create the encoded value
  if (removeCol==TRUE)
  {
    data<-data[ , -which(names(data) %in% c(col))]  
  }  
  data  
}

#' Read XPT to R dataframe
#' 
#' @param dataPath  Path to the source SEND data: data/studies/send/<study>
#' @param domain SDTM domain name on XPT file 
#'
#' @return R dataframe with same name as SDTM domain
#'
#' @examples
#' readXPT("data/studies/instem,"dm")

readXPT<-function(dataPath, domain)
{
  sourceFile <- paste0(dataPath, "/", domain, ".XPT")
  result <- sasxport.get(sourceFile)
  result  # return the dataframe
}


#' Shorten IRIs to use prefix+value or just the value
#' Shorten full IRIs to their prefixed values. 
#'
#' @param sourceDF     Dataframe to process 
#' @param colsToParse  List of column names to be parsed
#' @param usePrefix    replace IRI with prefix (TRUE) or just the value (FALSE)
#' 
#' @return DF with shortened values 
#' 
#' @examples
#' nodesAllData <- shortenIRI(sourceDF=nodesAllData, colsToParse=c("id"), usePrefix=TRUE)
shortenIRI <- function(sourceDF, colsToParse, usePrefix=TRUE)
{  
  
  # Use to build prefix list and to regex-out results to use prefixed value.
  # NOTE: IRI does NOT include <xxx> 
  prefixes <- read.table(header=T, text='
    prefix iri
    drt:      https://www.example.org/ucb/ToolsAndAutomation/drt#
    owl:      http://www.w3.org/2002/07/owl#
    meddra:   https://w3id.org/phuse/meddra#
    rdf:      http://www.w3.org/1999/02/22-rdf-syntax-ns#
    rdfs:     http://www.w3.org/2000/01/rdf-schema# 
    skos:     http://www.w3.org/2004/02/skos/core#
    time:     http://www.w3.org/2006/time#
    xsd:      http://www.w3.org/2001/XMLSchema# 
    ')
  
  # Each row in the dataframe
  for (i in 1:nrow(sourceDF))
  {
    # each column to process
    lapply(colsToParse, function(currCol){
      # Loop through each prefix value and test it against the current data value
      #  current value is: sourceDF[i, currCol]
      for (j in 1:nrow(prefixes))
      {
        # The IRI is present in the current field, proceed to replace it.
        if (grepl(prefixes[j,2], sourceDF[i,currCol] ))
        {  
          # prefixes[j,2]  : IRI to be searched and replaced
          # prefixes[j,1]  : Prefix value to use in place of IRI
          if(usePrefix){
            # Replace the URI/IRI with a prefix to form a qname
            parseStart <- gsub(prefixes[j,2], prefixes[j,1], sourceDF[i,currCol])
          }else{
            # Remove the URI/IRI and do not replace with a perfix. 
            #   Keep only the unprefixed value.
            parseStart <- gsub(prefixes[j,2], "", sourceDF[i,currCol])  
          }  
          # Clean up the remaining parts of the original IRI
          parseStart <- gsub("#", "", parseStart)
          parseEnd   <- gsub(">", "", parseStart)
          # Use this code to create a new column name, leaving the orig intact.
          # newCol <- paste0(currCol,"_pref")
          # sourceDF[i, newCol] <<- parseEnd
          sourceDF[i, currCol] <<- parseEnd
        }
      }
    })  # of of lapply over each col to be evaluated
  }
  sourceDF  # Return the modified dataframe
} # end of Function




#' Short IRIs to use prefixes
#' Shorten full IRIs to their prefixed values. 
#'
#' @param sourceDF     Dataframe to process 
#' @param colsToParse  List of column name to be parsed
#'
#' @return DF with prefix-only columns as <origname>_prefix
#'
#' @examples
#' nodesAllData <- IRItoPrefix(sourceDF=nodesAllData, colsToParse=c("id"))
IRItoPrefix <- function(sourceDF, colsToParse)
{  

  # Use to build prefix list and to regex-out results to use prefixed value.
  prefixes <- read.table(header=T, text='
    prefix iri
    owl:          <http://www.w3.org/2002/07/owl#> 
    meddra:       <https://w3id.org/phuse/meddra#>
    rdf:          <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
    rdfs:         <http://www.w3.org/2000/01/rdf-schema#> 
    skos:         <http://www.w3.org/2004/02/skos/core#> 
    time:         <http://www.w3.org/2006/time#> 
    xsd:          <http://www.w3.org/2001/XMLSchema#> 
  ')

  # Each row in the dataframe
  for (i in 1:nrow(sourceDF))
  {
    # each column to process
    lapply(colsToParse, function(currCol){
      # Loop through each prefix value and test it against the current data value
      #  current value is: sourceDF[i, currCol]
      for (j in 1:nrow(prefixes))
      {
        # The IRI is present in the current field, proceed to replace it.
        if (grepl(prefixes[j,2], sourceDF[i,currCol] ))
        {  
          # prefixes[j,2]  : IRI to be searched and replaced
          # prefixes[j,1]  : Prefix value to use in place of IRI
          parseStart <- gsub(prefixes[j,2], prefixes[j,1], sourceDF[i,currCol])
          parseStart <- gsub("#", "", parseStart)
          parseEnd   <- gsub(">", "", parseStart)
          # Use this code to crate a new column name, leavint the orig intact.
          # newCol <- paste0(currCol,"_pref")
          # sourceDF[i, newCol] <<- parseEnd
          sourceDF[i, currCol] <<- parseEnd
        }
      }
    })  # of of lapply over each col to be evaluated
  }
  sourceDF  # Return the modified dataframe
} # end of Function
