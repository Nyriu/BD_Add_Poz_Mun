# Installazione del pacchetto 
#install.packages("RPostgreSQL")

# Caricamento del pacchetto (in teoria basta solo uno di questi due ma a me servono entrambe)
require("RPostgreSQL")
library("RPostgreSQL")

# Caricamento del driver
drv <- dbDriver("PostgreSQL")

# Connessione al db 
con <- dbConnect(drv, 
                 dbname="bd_18_paolo_addis",
                 host="158.110.145.186",
                 port="5432",
                 user="bd_18_paolo_addis",
                 password="corso_bd_2018")


#################################### AREA 51 #########################################

# Setta il path sullo schema "ospedale"
dbGetQuery(con, "set search_path to ospedale;")

# Query di test (mostra il dataframe)
dbGetQuery(con, "select * from paziente;")

# Query memorizzata in un dataframe (una variabile che contiene il dataframe)
res <- dbGetQuery(con, "select * from paziente;")


####### TEST POPOLAMENTO TABELLA PAZIENTE

# Lettura dei nomi da file
v_nomi <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\nomi.txt")

# Lettura dei cognomi da file
v_cognomi <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\cognomi.txt")

# Creazione del dataframe
pazienti_df <- data.frame(
    nome=sample(v_nomi, 10000, replace = T),
    cognome=sample(v_cognomi, 10000, replace = T)
)

# Inserimento del dataframe nella tabella paziente del db
dbWriteTable(con, 
             name="paziente",
             value=pazienti_df,
             append=F,
             row.names=T)




######################################################################################

# Bisogna generare gli attibuti per le varie tabelle.
# In particolare bisogna fare attenzione al formato di:
# codici (per quello fiscale bisogna scelgiere quanto realistico)
# date
#


#  Disconnessione dal db 
dbDisconnect(con)
