

# STRUTTURA DEL FILE:
# Nella prima parte vengono creati tutti i popoli delle varie tabelle e vengono memorizzati nei csv
# Nella seconda parte avviene il popolamento vero e proprio delle tabelle nel db dopo la connessione
# Nella terza parte verranno eseguiti i test per i vari grafici










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
paz <- pazienti[,c(2,5)]

# Creo un vettore di lughezza quanto i pazienti del db
# Assegno a ogni cella un numero random da 1 a 5
nric <- sample(1:5, nrow(paz), replace=T)

# Funzione di creazione del codice del ricovero
cric <- function(n){
    paste0("RIC",n,collapse="")
}


# GENERAZIONE DEI RICOVERI DEL PRIMO PAZIENTE

n_paziente = 1

#
# Creazione della data di inizio e della data di fine
#

# Prendo la data attuale e quella di nascita
dnasc = as.Date(paz[n_paziente,2])
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
k = 1
while(k <= nricoveri){

    v_date_i[k] = sample(seq(as.Date(v_intervalli[k]),as.Date(v_intervalli[k+1]),by="day"),1 , replace=T)

    v_date_f[k] = sample(seq(as.Date(v_date_i[k]),as.Date(v_intervalli[k+1]),by="day"),1 , replace=T)

    k= k+1
}

#
# Fine creazione date
#

# Seleziono un motivo random 
moti = sample(mot,1,replace=T)

# Seleziono una divisione ospedaliera random
divis_osp = sample(divosp,1,replace=T)

# Prendo il cf del paziente
pazio = paz[n_paziente,1]


#
# Creo il dataframe dei ricoveri per il primo paziente
#

# Creo il dataframe del primo ricovero

# Creazione del codice
n_ricovero = 1
codice_ric = cric(n_ricovero)

k = 1
ricoveri_df <- data.frame(
                    cod_ric = codice_ric,
                    data_i = v_date_i[k],
                    data_f = v_date_f[k],
                    motivo = moti,
                    div_osp = divis_osp,
                    paziente = pazio
                    )

# Ci appiccico gli altri eventuali ricoveri
k = k+1
while(k <= nricoveri){
    
    n_ricovero = n_ricovero + 1
    codice_ric = cric(i)
    moti = sample(mot,1,replace=T)
    divis_osp = sample(divosp,1,replace=T)

    altroricovero <- data.frame(
                        cod_ric = codice_ric,
                        data_i = v_date_i[k],
                        data_f = v_date_f[k],
                        motivo = moti,
                        div_osp = divis_osp,
                        paziente = pazio
                        )

    ricoveri_df <- rbind(ricoveri_df,altroricovero)
    
    k = k+1
}


for(n_paziente in 2:nrow(paz)){
    pazio = paz[n_paziente,1]
    dnasc = as.Date(paz[n_paziente,2])
    datt <- as.Date("2019-04-11")
    nricoveri <- nric[n_paziente]
    intervallo = floor((datt-dnasc) / nricoveri)
    v_intervalli = vector()
    class(v_intervalli) <- "Date"
    dtemp = dnasc
    v_intervalli[1] = dtemp
    for(k in 2:(nricoveri+1)){
        dtemp = dtemp + intervallo
        v_intervalli[k] = dtemp
    }
    v_date_i <- vector()
    class(v_date_i) <- "Date"
    v_date_f <- vector()
    class(v_date_f) <- "Date"
    k = 1
    while(k <= nricoveri){
        v_date_i[k] = sample(seq(as.Date(v_intervalli[k]),as.Date(v_intervalli[k+1]),by="day"),1 , replace=T)
        v_date_f[k] = sample(seq(as.Date(v_date_i[k]),as.Date(v_intervalli[k+1]),by="day"),1 , replace=T)
        k= k+1
    }
    k = 1
    while(k <= nricoveri){

        n_ricovero = n_ricovero + 1
        codice_ric = cric(n_ricovero)
        moti = sample(mot,1,replace=T)
        divis_osp = sample(divosp,1,replace=T)

        altroricovero <- data.frame(
                            cod_ric = codice_ric,
                            data_i = v_date_i[k],
                            data_f = v_date_f[k],
                            motivo = moti,
                            div_osp = divis_osp,
                            paziente = pazio
                            )
        ricoveri_df <- rbind(ricoveri_df,altroricovero)
        k = k+1
    }

}

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

# Creo il dataframe dei pazienti 
pazienti <- read.csv("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\pazienti.csv", stringsAsFactors = FALSE)

# Creo il dataframe dei ricoveri
ricoveri <- read.csv("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\ricoveri.csv", stringsAsFactors = FALSE)

# Creo il join dei due dataframe
paz_x_ric <- merge(pazienti, ricoveri, by.x="cf", by.y="paziente" )

# Seleziono solo le colonne che mi servono: cf, cod_ric, data_i, data_f
utile <- paz_x_ric[,c(1,12,13,14)]

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


# Dichiaro una funzione per creare nuovi dataframe per le diagnosi
new_empty_diagnosi_df <- function(){
    data.frame(
        cod_dia=character(),
        data_dia=as.Date(character()),
        cod_pat=character(),
        grav_pat=character(),
        medico=character(),
        paziente=character(),
        ricovero=character()
    )
}

# Dichiaro una funzione che crea un blocchetto di diagnosi per un ricovero
creazione_blocchetto <- function(utile, indice_tupla,indice_df){
    # Seleziono la tupla contenente il ricovero di cui devo popolare
    tupla = utile[indice_tupla,]

    blocchetto_diagnosi_di_un_ricovero = new_empty_diagnosi_df()

    # Creazione delle date delle diagnosi 
    # Prendo la data di inizio e fine del ricovero
    dinizio = as.Date(tupla[,3])
    dfine <- as.Date(tupla[,4])
    # Considero tante date random in questo intervallo quante quelle in n_diagnosi
    v_date <- sample(seq(dinizio,dfine,by="day"),n_diagnosi[indice_tupla],replace=T)
    # Seleziono tanti codici icd10 quanti il numero di diagnosi
    v_codpat <- sample(icd10, n_diagnosi[indice_tupla],replace=T)
    # Creo un vettore di gravità delle patologie diagnosticate
    v_gravita <- sample(c("Alta","Bassa"),n_diagnosi[indice_tupla],replace=T)
    # Seleziono i medici a caso 
    v_med <- sample(medici, n_diagnosi[indice_tupla], replace=T)

    # Creo un nuova riga di dataframe per ogni diagnosi e la appendo al principale
    for(indice_diagnosi_ricovero in 1:n_diagnosi[indice_tupla]){
        
        altradiagnosi<- data.frame(
                            cod_dia=cdia(indice_df),
                            data_dia=v_date[indice_diagnosi_ricovero],
                            cod_pat=v_codpat[indice_diagnosi_ricovero],
                            grav_pat=v_gravita[indice_diagnosi_ricovero],
                            medico=v_med[indice_diagnosi_ricovero],
                            paziente=tupla[1],
                            ricovero=tupla[2]
        )

        blocchetto_diagnosi_di_un_ricovero <- rbind(blocchetto_diagnosi_di_un_ricovero,altradiagnosi)

        indice_df = indice_df + 1
    }

    blocchetto_diagnosi_di_un_ricovero
}

# Funzione per calcolare l'indice di diagnosi per il successivo blocchetto    
conta_indice_df <- function(indice_tupla,n_diagnosi){
    sum = 0
    if(indice_tupla == 1){
        1
    } else {
        for(i in 1:(indice_tupla-1)){
            sum = sum + n_diagnosi[i]
        }
        sum = sum + 1 
        sum
    } 
}

# Creo dei dataframe temporanei per l'ottimizzazione
diagnosi_di_piu_ricoveri = new_empty_diagnosi_df()
diagnosi_df_parte_1 = new_empty_diagnosi_df()
diagnosi_df_parte_2 = new_empty_diagnosi_df()

# Divido l'insieme dei ricoveri in p parti PARI
p = 24
for(k in 1:p){

    # Per ogni parte genero dei blocchi di diagnosi componendo blocchetti di diagnosi di singoli ricoveri
    for(indice_tupla in (ceiling(  n_tuple * ((k-1)/p) ) + 1) : ceiling( n_tuple * k/p )   ){ 
        indice_df = conta_indice_df(indice_tupla, n_diagnosi)  
        diagnosi_di_piu_ricoveri <- rbind(diagnosi_di_piu_ricoveri, creazione_blocchetto(utile,indice_tupla,indice_df))
    }

    # Divisione del df per ottimizzazione generale
    if(k <= p/2){
        diagnosi_df_parte_1 <- rbind(diagnosi_df_parte_1,diagnosi_di_piu_ricoveri)
    } else {
        diagnosi_df_parte_2 <- rbind(diagnosi_df_parte_2,diagnosi_di_piu_ricoveri)
    }

    # Svuoto il df intermediario per evitare duplicati
    diagnosi_di_piu_ricoveri = new_empty_diagnosi_df()
}

# Creo il dataframe finale
diagnosi_df = new_empty_diagnosi_df()

# Incorporo tutto nel df finale
diagnosi_df <- rbind(diagnosi_df_parte_1,diagnosi_df_parte_2)


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
