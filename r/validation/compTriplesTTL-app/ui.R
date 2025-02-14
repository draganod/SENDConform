#______________________________________________________________________________
# FILE: r/validation/compTriplesTTL-appp/ui.R
# DESC: Compare triples in two TTL files, starting at a named Subject.
#         Used to compare instance data created in the Ontology approach with
#         data converted using R
# SRC :
# IN  : TTL files in a local folder. Typically /data/rdf
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
#       
# TODO: 
#______________________________________________________________________________

fluidPage(
  titlePanel("Compare Instance Data: Ontology vs. R"),
  fluidRow (
      column(4, fileInput('fileOnt', paste("Ontology TTL"))),
      column(4, fileInput('fileR',   'R-generated TTL')
      ),
      column(3, textInput('qnam', "Subject QName", value = "cj16050:Animal_00M01"))
  ),
  radioButtons("comp", "Compare:",
                c("In R, not in Ontology" = "inRNotOnt",
                  "In Ontology, not in R" = "inOntNotR")),    
  h4("Unmatched Triples:",
    style= "color:#e60000"),
  hr(),    
  tableOutput('unmatched'), 
  fluidRow (
    column(6, 
      h4("Ontology Triples",
        style= "color:#000099"),
      tableOutput('ontSP')),
    column(6, 
      h4("R Triples",
        style= "color:#00802b"),
      tableOutput('rSP'))
  )  
)    