

# STRUTTURA DEL FILE:
# Nella prima parte vengono creati tutti i popoli delle varie tabelle e vengono memorizzati nei csv
# Nella seconda parte avviene il popolamento vero e proprio delle tabelle nel db dopo la connessione
# Nella terza parte verranno eseguiti i test per i vari grafici




















# Procedura per l'ottimizzazione del binding di liste di dataframes
# Input: Lista di dataframe
# Restituisce un dataframe 
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

    # Prendo il cf del paziente
    cf_paz = utile[n_paziente,1]

    # Genero tutti i ricoveri per quel determinato paziente
    for(k in 1:nricoveri){

        ricovero <- data.frame(
                        cod_ric = indice_ricovero,
                        data_i = v_date_i[k],
                        data_f = v_date_f[k],
                        motivo = sample(mot,1,replace=T),
                        div_osp = sample(divosp,1,replace=T),
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
                            cod_dia=indice_df,
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
colnames(diagnosi_df) <- c("cod_dia","data_dia","cod_pat","grav_pat","medico","paziente","ricovero")

# Salvo il dataframe in un csv
write.csv(diagnosi_df, file("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\diagnosi.csv"))



















#######                                       #######
####### POPOLO PER LA TABELLA PRINCIPI ATTIVI #######
#######                                       #######


# Creo il dataframe dei principi attivi
pr_att <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\farmaco\\pr_attivo.txt")

lista_df_principi <- list()

# Inserisco tutti i principi in un dataframe
for(i in 1:length(pr_att)){

    principio <- data.frame(nome=pr_att[i])
    lista_df_principi[[i]] <- principio

}

pr_attivi_df <- megabind(lista_df_principi) 
names(pr_attivi_df)[names(pr_attivi_df) == 'x'] <- "nome" # sto casino perchè il df ha solo una colonna

write.csv(pr_attivi_df, file("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\pr_attivi.csv"))



















#######                               #######
####### POPOLO PER LA TABELLA FARMACO #######
#######                               #######

# Creo i df per aziende, farmaci
aziende <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\farmaco\\azienda.txt",stringsAsFactors = FALSE)

nome_farmaci <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\farmaco\\farmaco.txt", stringsAsFactors = FALSE)


lista_df_farmaci <- list()

for(i in 1:length(nome_farmaci)){

    farmaco <- data.frame(
                    nome_comm=nome_farmaci[i],
                    azienda_prod=sample(aziende,1,replace=T),
                    dose_gg_racc=sample(1:3,1,replace=T)
                    )

    lista_df_farmaci[[i]] <- farmaco

}

farmaci_df <- megabind(lista_df_farmaci)

write.csv(farmaci_df, file("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\farmaci.csv"))



















#######                                #######
####### POPOLO PER LA TABELLA CONTIENE #######
#######                                #######

nome_farmaci <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\farmaco\\farmaco.txt")

pr_att <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\farmaco\\pr_attivo.txt")

conta_quant <- function(n){
    paste(n,"mg",collapse="")
}

lista_df_contiene <- list()

# I principi attivi sono meno dei farmaci 
for(i in 1:length(pr_att)){

    contenuto <- data.frame(
                        farmaco=nome_farmaci[i],
                        pr_attivo=pr_att[i],
                        quantita=conta_quant(sample(seq(5,40,by=5),1,replace=T))
                        )
    
    lista_df_contiene[[i]] <- contenuto

}

# Aggiungo i farmaci mancanti 
for(i in (length(pr_att)+1):length(nome_farmaci)){

    contenuto <- data.frame(
                        farmaco=nome_farmaci[i],
                        pr_attivo=sample(pr_att, 1, replace=T),
                        quantita=conta_quant(sample(seq(5,40,by=5),1,replace=T))
                        )

    lista_df_contiene[[i]] <- contenuto

}

# Aggiungo un decimo dei farmaci in modo da averne alcuni con doppio principio attivo 
for(i in (length(nome_farmaci)+1):(floor( length(nome_farmaci) + (length(nome_farmaci)/10) ) ) ){

    contenuto <- data.frame(
                        farmaco=sample(nome_farmaci,1, replace=T),
                        pr_attivo=sample(pr_att, 1, replace=T),
                        quantita=conta_quant(sample(seq(5,40,by=5),1,replace=T))
                        )

    lista_df_contiene[[i]] <- contenuto

}

contiene_df <- megabind(lista_df_contiene)

write.csv(contiene_df, file("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\contiene.csv"))



















#######                               #######
####### POPOLO PER LA TABELLA TERAPIA #######
#######                               #######

farmaci <- read.csv("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\farmaci.csv", stringsAsFactors = FALSE)

msomm <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\farmaco\\somministrazione.txt")

# Funzione di creazione del codice della terapia
cter <- function(n){
    paste0("TER",n,collapse="")
}

lista_df_terapie <- list()

for(i in seq( 1 , (length(farmaci[,1])*3) , by=3 )  ){

    v_msomm <- sample(msomm, 3, replace = FALSE)
    
    s= 1
    for(k in i : (i+2)){
        
        terapia <- data.frame(
                    cod_ter=k,
                    dose_gio=sample(c(1,2,3),1,replace=T),
                    mod_somm=v_msomm[s],
                    farmaco=farmaci[(floor(i/3)+1),2]
                    )  
    
        lista_df_terapie[[k]] <- terapia
        s = s + 1
    }
     
}

terapie_df <- megabind(lista_df_terapie)

write.csv(terapie_df,  file("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\terapie.csv") )



















#######                                          #######
####### POPOLO PER LA TABELLA TERAPIA PRESCRITTA #######
#######                                          #######

terapie <- read.csv("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\terapie.csv", stringsAsFactors = FALSE)

diagnosi <- read.csv("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\diagnosi.csv", stringsAsFactors = FALSE)

ricoveri <- read.csv("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\ricoveri.csv", stringsAsFactors = FALSE)

medici <- readLines("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\R\\diagnosi\\medico.txt")

pazienti <- read.csv("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\pazienti.csv", stringsAsFactors = FALSE)

cross <- merge(x=ricoveri, y=diagnosi, by.x="cod_ric", by.y="ricovero")

utile <- cross[,c(1,3,4,7,9,10)]
colnames(utile) <- c("cric","r_data_i","r_data_f","paz","cdia","d_data")

# Prendo tutti i pazienti in ordine alfabetico
pazienti <- pazienti[order(pazienti$cf),]
pazienti <- pazienti[,2]


# Ordino il dataframe per ordine alfabetico del cf paziente e la data della diagnosi
utile_1 <- utile[order(utile$paz,utile$r_data_i,utile$d_data),]


lista_df_tprescritte <- list()
indice_tp = 1

for(i in 1:(length(pazienti))){

    # Per ogni paziente recupero tutte le diagnosi
    paz_att <- pazienti[i]

    codici_diagnosi_per_singolo_paziente <- utile_1[which(utile_1$paz == paz_att), 5]
    date_tutte_diagnosi_per_singolo_paziente <- utile_1[which(utile_1$paz == paz_att), 6]

    k = 1
    while(k <= length(codici_diagnosi_per_singolo_paziente)){
        
        # Stabilisco delle probabilità per sapere se la patologia ha una cura
        prob_cura = sample(1:10,1,replace=T)
        prob_eff_coll = 1
        effcoll = NA


        if(prob_cura != 10){

            if(k < length(codici_diagnosi_per_singolo_paziente)){
               
                di = sample(seq(as.Date(date_tutte_diagnosi_per_singolo_paziente[k]), as.Date(date_tutte_diagnosi_per_singolo_paziente[k+1]), by="day"), 1, replace=T)
                df = sample(seq(di, as.Date(date_tutte_diagnosi_per_singolo_paziente[k+1]), by="day"), 1, replace=T)
               
                prob_eff_coll = sample(1:20,1,replace=T)

                if(prob_eff_coll == 1){
                    effcoll = codici_diagnosi_per_singolo_paziente[k+1]
                }
            
            } else {
                di = sample(seq(as.Date(date_tutte_diagnosi_per_singolo_paziente[k]), as.Date("2019-04-11"), by="day"), 1, replace=T)
                df = sample(seq(di, as.Date("2019-04-11"), by="day"), 1, replace=T)
            }

            terapia_prescritta <- data.frame(
                            data_i = di,
                            data_f = df,
                            med_presc = sample(medici, 1, replace=T),
                            diagnosi = codici_diagnosi_per_singolo_paziente[k],
                            terapia = sample(terapie[,2],1,replace=T),
                            coll_dia = effcoll
                            )

            lista_df_tprescritte[[indice_tp]] <- terapia_prescritta
            indice_tp = indice_tp + 1


            k = k + 1

            if((k < (length(codici_diagnosi_per_singolo_paziente))) && (prob_eff_coll == 1)){
                k = k + 1
            }
        
        }
    }

}

terapie_prescritte_df <- megabind(lista_df_tprescritte)

write.csv(terapie_prescritte_df, file("C:\\Users\\addis\\Desktop\\Progetto Database\\BD_Add_Poz_Mun\\implementazione\\popoliCSV\\terapie_prescritte.csv"))




















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

















