

# STRUTTURA DEL FILE:
# Nella prima parte vengono creati tutti i popoli delle varie tabelle e vengono memorizzati nei csv
# Nella seconda parte avviene il popolamento vero e proprio delle tabelle nel db dopo la connessione
# Nella terza parte verranno eseguiti i test per i vari grafici



#######                                #######
####### POPOLO PER LA TABELLA PAZIENTE #######
#######                                #######

# Lettura dei nomi
v_nomi <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\nomi.txt")

# Lettura dei cognomi
v_cognomi <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\cognomi.txt")

# Lettura dei luoghi
v_luoghi <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\luoghi.txt")

# Creazione dataframe prov_res,reg_app,ulss
pru <- read.csv("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\pro-reg-ulss.csv", stringsAsFactors = FALSE)

# Funzione per la generazione del cf farlocco
cf_gen <- function(nome, cognome, data) {
    NOM  <- toupper(substr(nome,1,3))
    COG1 <- toupper(substr(cognome,1,2))
    COG2 <- if(nchar(cognome)==3){
               toupper(substr(cognome,3,3))
            } else if (nchar(cognome)>3) {
               toupper(substr(cognome,4,4))
            } else {
                "XXX"
            }
    COG  <- toupper(paste0(COG1,COG2,collapse=""))
    DA   <- substr(data,9,10)
    digits = 0:9
    fine = c(sample(LETTERS, 1, replace=T),
             sample(digits , 2, replace=T),
             sample(LETTERS, 1, replace=T),
             sample(digits , 3, replace=T),
             sample(LETTERS, 1, replace=T)) 
    FINE <- paste0(fine,collapse="")
    cf = paste0(NOM,COG,DA,FINE, collapse="")
}

# GENERAZIONE DEL PAZIENTE 0 !!!!!

# Scelto nome a caso
nom = sample(v_nomi,1,replace=T) 

# Scelto cognome a caso
cog = sample(v_cognomi,1,replace=T)

# Data di nascita in range
dnasc = sample(seq(as.Date('1910/01/01'), as.Date('2019/04/01'), by="day"), 1, replace = T)

# CF basato su nome, cognome, data di nascita e altri caratteri random
cfi = cf_gen(nom, cog, dnasc)

# Scelto luogo di nascita
lnasc = sample(v_luoghi,1,replace=T)

# Estrae una riga dal dataframe pru
df_line <- pru[sample(1:nrow(pru),1),]

# Crea un vettore di stringhe di elementi del df
prreul <- strsplit(paste(df_line,collapse=" "), " ")

# Inizializza tutti i parametri restanti
pres = prreul[[1]][1]
rapp = prreul[[1]][2]
ul = prreul[[1]][3]
# Nel caso in cui sia residente in regione Friuli annulla i parametri successivi
if(prreul[[1]][2] == "Friuli-Venezia-Giulia"){
    rapp = NA
    ul = NA
}

# Inizialmente questo valore è settato a 0????
tot_gg_ric = 0


# Creazione del dataframe con l'inserimento del paziente 0
pazienti_df <- data.frame(
                    cf=cfi,
                    cognome=cog,
                    nome=nom,
                    data_nasc=dnasc,
                    luogo_nasc=lnasc,
                    prov_res=pres,
                    reg_app=rapp,
                    ulss=ul,
                    tot_gg_ric=0
                    )


# Esecuzione del ciclo per la generazione di tutti gli altri pazienti
for (i in 1:10000) {
    nom = sample(v_nomi,1,replace=T)
    cog = sample(v_cognomi,1,replace=T)
    dnasc = sample(seq(as.Date('1910/01/01'), as.Date('2019/04/01'), by="day"), 1, replace = T)
    cfi = cf_gen(nom, cog, dnasc)
    lnasc = sample(v_luoghi,1,replace=T)
    df_line <- pru[sample(1:nrow(pru),1),]
    prreul <- strsplit(paste(df_line,collapse=" "), " ")
    pres = prreul[[1]][1]
    rapp = prreul[[1]][2]
    ul = prreul[[1]][3]
    if(prreul[[1]][2] == "Friuli-Venezia-Giulia"){
        rapp = NA
        ul = NA
    }
    tot_gg_ric = 0

    altropazzo <- data.frame(
            cf=cfi,
            cognome=cog,
            nome=nom,
            data_nasc=dnasc,
            luogo_nasc=lnasc,
            prov_res=pres,
            reg_app=rapp,
            ulss=ul,
            tot_gg_ric=0
            )

    pazienti_df <- rbind(pazienti_df, altropazzo)
}


# MEMORIZZAZIONE del dataframe nel file csv
write.csv(pazienti_df, file("pazienti.csv"))





#######                                #######
####### POPOLO PER LA TABELLA RICOVERO #######
#######                                #######

# TODO TADAN TUDUN







####################################################
##########                                ##########
###            INTERAZIONE CON IL DB             ###
##########                                ##########
#################################################### 


# Installazione del pacchetto 
# install.packages("RPostgreSQL")

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


######################################################################################
#################################### AREA 51 #########################################
######################################################################################


# Setta il path sullo schema "ospedale"
dbGetQuery(con, "set search_path to ospedale;")

# Query di test (mostra il dataframe)
dbGetQuery(con, "select * from paziente;")

# Query memorizzata in un dataframe (una variabile che contiene il dataframe)
res <- dbGetQuery(con, "select * from paziente;")

# !!!ATTENZIONE!!! ANCORA NON TESTATO
# Inserimento del dataframe nella tabella paziente del db 
dbWriteTable(con, 
             name="paziente",
             value=pazienti_df,
             append=F,
             row.names=T)


######################################################################################
######################################################################################
######################################################################################

#  Disconnessione dal db 
dbDisconnect(con)
