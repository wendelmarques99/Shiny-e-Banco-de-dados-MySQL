library(keyring)
library(RMySQL)
library(shiny)

# Proteger nossa senha
keyring::key_set(service = "my-database",
                 username = "myusername")

# Conectando com o Banco de dados remoto
conn <- RMySQL::dbConnect(RMySQL::MySQL(),
                          user = "sql4421522",
                          host = "sql4.freemysqlhosting.net",
                          password = keyring::key_get("my-database", "myusername"),
                          port = 3306)


# Adicionando a base mtcars na base    
RMySQL::dbSendQuery(conn, "USE sql4421522;")

RMySQL::dbWriteTable(conn, "mtcars", mtcars, overwrite = TRUE)

# Vendo o resultadp
res <- RMySQL::dbSendQuery(conn, "SELECT * FROM mtcars;")

data <- RMySQL::dbFetch(res)

head(data)

# Criando um shiny app basico para conectar com  a base remota e printar os dados na tela
ui <- shiny::fluidPage(
  
  tableOutput("table")
)

server <- function(input, output, session) {
  
  conn <- RMySQL::dbConnect(RMySQL::MySQL(),
                            user = "sql4421522",
                            host = "sql4.freemysqlhosting.net",
                            password = keyring::key_get("my-database", "myusername"),
                            port = 3306)
  
  RMySQL::dbSendQuery(conn, "USE sql4421522;")
  res <- dbSendQuery(conn, "SELECT * FROM mtcars;")
  data <- dbFetch(res)
  RMySQL::dbDisconnect(conn)
  output$table <- renderTable(data) 
  
}

shiny::shinyApp(ui, server)

# Adicionando uma nova linha na base    
query_insert <- paste0("INSERT INTO mtcars(",
                       paste0(colnames(data), collapse = ","),
                       ")values('Fusca',1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);")


dbSendQuery(conn, query_insert)

# Dá F5 no app para ver se foi atualizado

