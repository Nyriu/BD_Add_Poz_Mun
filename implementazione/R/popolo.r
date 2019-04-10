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

# Generazione delle date di nascita
# Formato YYYY-MM-DD
data_nasc <- sample(seq(as.Date('1910/01/01'), as.Date('2019/04/01'), by="day"), 10000, replace = T)



# Creazione del dataframe
pazienti_df <- data.frame(
    nome=sample(v_nomi, 10000, replace = T),
    cognome=sample(v_cognomi, 10000, replace = T)
    data_nasc,
    
)

# Inserimento del dataframe nella tabella paziente del db
dbWriteTable(con, 
             name="paziente",
             value=pazienti_df,
             append=F,
             row.names=T)




######################################################################################

#  Disconnessione dal db 
dbDisconnect(con)
