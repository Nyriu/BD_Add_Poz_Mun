

# STRUTTURA DEL FILE:
# Nella prima parte vengono creati tutti i popoli delle varie tabelle e vengono memorizzati nei csv
# Nella seconda parte avviene il popolamento vero e proprio delle tabelle nel db dopo la connessione
# Nella terza parte verranno eseguiti i test per i vari grafici




















# Procedura per l'ottimizzazione del binding di liste di dataframes
megabind <- function(lista_df){
    # Un indice parte dall'inzio
    i = 1
    # Un indice parte dal fondo
    for(f in length(lista_df): 1){
        # Se si incontrano il primo riparte dall'inizio
        if(i >= f){
            i = 1
        } 
        # Se sono uguali ho finito
        if(i != f){
            lista_df[[i]] = rbind(lista_df[[i]],lista_df[[f]])
        }
        
        i = i + 1

    }
    # Restituisco il dataframe completo
    lista_df[[1]]
}



















#######                                #######
####### POPOLO PER LA TABELLA PAZIENTE #######
#######                                #######

# Lettura dei nomi
v_nomi <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\paziente\\nomi.txt")

# Lettura dei cognomi
v_cognomi <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\paziente\\cognomi.txt")

# Lettura dei luoghi
v_luoghi <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\paziente\\luoghi.txt")

# Creazione dataframe prov_res,reg_app,ulss
pru <- read.csv("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\paziente\\pro-reg-ulss.csv", stringsAsFactors = FALSE)

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


lista_df_pazienti <- list()

for(i in 1:10000){
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

    paziente <- data.frame(
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

    lista_df_pazienti[[i]] <- paziente

}

pazienti_df <- megabind(lista_df_pazienti)


# MEMORIZZAZIONE del dataframe pazienti_df nel file csv
write.csv(pazienti_df, file("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\pazienti.csv"))




















#######                                #######
####### POPOLO PER LA TABELLA RICOVERO #######
#######                                #######

# Serve che ogni paziente abbia in media 3 ricoveri

# Creo il dataframe dei pazienti
pazienti <- read.csv("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\pazienti.csv", stringsAsFactors = FALSE)

# Creo il dataframe delle divisioni ospedaliere
divosp <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\ricovero\\divisioniOsp.txt")

# Creo il dataframe dei motivi di ricovero
mot <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\ricovero\\motivi.txt")

# Del dataframe dei pazienti mi serve solo il CF e la data di nascita
utile <- pazienti[,c(2,5)]

# Creo un vettore di lughezza quanto i pazienti del db
# Assegno a ogni cella un numero random da 1 a 5
nric <- sample(1:5, nrow(utile), replace=T)

# Funzione di creazione del codice del ricovero
cric <- function(n){
    paste0("RIC",n,collapse="")
}

# Creo una lista per memorizzare i ricoveri
lista_df_ricoveri <- list()

# Inizializzo un contatore per il codice dei ricoveri
indice_ricovero = 1

for(n_paziente in 1: nrow(utile)){
    
    # Prendo la data attuale e quella di nascita per creare la data di inizio e fine del ricovero
    dnasc = as.Date(utile[n_paziente,2])
    datt <- as.Date("2019-04-11")
    # Prendo il numero di ricoveri random per questo paziente
    nricoveri <- nric[n_paziente]
    # Conto il numero di giorni tra un intervallo netto e l'altro 
    intervallo = floor((datt-dnasc) / nricoveri)
    # Creo un vettore di intervalli di date
    v_intervalli = vector()
    class(v_intervalli) <- "Date"

    # Lo popolo
    dtemp = dnasc
    v_intervalli[1] = dtemp
    for(k in 2:(nricoveri+1)){
        dtemp = dtemp + intervallo
        v_intervalli[k] = dtemp
    }

    # Creo un vettore per le date di inizio
    v_date_i <- vector()
    class(v_date_i) <- "Date"
    #Creo un vettore per le date di fine
    v_date_f <- vector()
    class(v_date_f) <- "Date"

    # Popolo i due vettori
    for(k in 1:nricoveri){

        v_date_i[k] = sample(seq(as.Date(v_intervalli[k]),as.Date(v_intervalli[k+1]),by="day"),1 , replace=T)

        v_date_f[k] = sample(seq(as.Date(v_date_i[k]),as.Date(v_intervalli[k+1]),by="day"),1 , replace=T)
    }

    # Seleziono un motivo random 
    moti = sample(mot,1,replace=T)

    # Seleziono una divisione ospedaliera random
    divis_osp = sample(divosp,1,replace=T)

    # Prendo il cf del paziente
    cf_paz = utile[n_paziente,1]

    # Creazione del codice
    codice_ric = cric(indice_ricovero)

    # Genero tutti i ricoveri per quel determinato paziente
    for(k in 1:nricoveri){

        ricovero <- data.frame(
                        cod_ric = codice_ric,
                        data_i = v_date_i[k],
                        data_f = v_date_f[k],
                        motivo = moti,
                        div_osp = divis_osp,
                        paziente = cf_paz
                        )

        lista_df_ricoveri[[indice_ricovero]] <- ricovero
        indice_ricovero = indice_ricovero + 1

    }
}

ricoveri_df <- megabind(lista_df_ricoveri)


# MEMORIZZAZIONE del dataframe ricoveri nel file csv
write.csv(ricoveri_df, file("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\ricoveri.csv"))

# TODO ricoveri senza fine 
# TODO uno con 6 ricoveri




















#######                                #######
####### POPOLO PER LA TABELLA DIAGNOSI #######
#######                                #######


# Per ogni paziente esistono in media 12 diagnosi 
# Cioè per ogni ricovero in media 4 diagnosi

# Genero 1000 codici ICD10
icd10 <- vector()

for(i in 1:999){
    cd = c(sample(LETTERS,1,replace=T),
            sample(  0:9  ,2,replace=T))
    cd = paste(cd,collapse="")
    icd10[i] = cd
}

#Creo il dataframe dei medici
medici <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\diagnosi\\medico.txt")

# Creo il dataframe dei ricoveri
ricoveri <- read.csv("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\ricoveri.csv", stringsAsFactors = FALSE)

# Seleziono solo le colonne che mi servono: cf, cod_ric, data_i, data_f
utile <- ricoveri[,c(2,3,4,7)]

# Memorizzo in una variabile il numero di tuple utili
n_tuple <- nrow(utile)

# Per ogni tupla utile devo generare un valore random di diagnosi per mantenere la media di 4 a ricovero
n_diagnosi <- vector()
for(i in 1:n_tuple){
    n_diagnosi[i] = sample(1:7,1,replace=T)
}

# Funzione di creazione del codice del ricovero
cdia <- function(n){
    paste0("DIA",n,collapse="")
}

# Diachiaro un vettore di date utile in seguito
v_date <- vector()
class(v_date) <- "Date"

# Creo una lista per memorizzare i dataframe delle diagnosi
lista_df_diagnosi <- list()

# Inizializzo un indice per il codice delle diagnosi
indice_df = 1


for(indice_tupla in 1 : n_tuple){

    # Seleziono una tupla
    tupla = utile[indice_tupla,]    

    # Creazione delle date delle diagnosi 
    # Prendo la data di inizio e fine del ricovero
    dinizio = as.Date(tupla[,2])
    dfine <- as.Date(tupla[,3])
    # Considero tante date random in questo intervallo quante quelle in n_diagnosi
    v_date <- sample(seq(dinizio,dfine,by="day"),n_diagnosi[indice_tupla],replace=T)
    # Seleziono tanti codici icd10 quanti il numero di diagnosi
    v_codpat <- sample(icd10, n_diagnosi[indice_tupla],replace=T)
    # Creo un vettore di gravità delle patologie diagnosticate
    v_gravita <- sample(c("Alta","Bassa"),n_diagnosi[indice_tupla],replace=T)
    # Seleziono i medici a caso 
    v_med <- sample(medici, n_diagnosi[indice_tupla], replace=T)

    # Creo un nuovo dataframe di una riga contenente una sola diagnosi 
    for(indice_diagnosi_ricovero in 1:n_diagnosi[indice_tupla]){
        
        diagnosi <- data.frame(
                            cod_dia=cdia(indice_df),
                            data_dia=v_date[indice_diagnosi_ricovero],
                            cod_pat=v_codpat[indice_diagnosi_ricovero],
                            grav_pat=v_gravita[indice_diagnosi_ricovero],
                            medico=v_med[indice_diagnosi_ricovero],
                            paziente=tupla[4],
                            ricovero=tupla[1]
        )

        # Inserisco la nuova diagnosi in una lista
        lista_df_diagnosi[[indice_df]] <- diagnosi
        indice_df = indice_df + 1
    }
}

# Creo il dataframe completo delle diagnosi
diagnosi_df <- megabind(lista_df_diagnosi)

# Salvo il dataframe in un csv
write.csv(diagnosi_df, file("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\diagnosi.csv"))




























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

















