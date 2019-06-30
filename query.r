

####################################################
##########                                ##########
###            INTERAZIONE CON IL DB             ###
##########                                ##########
#################################################### 


# Installazione del pacchetto 
# install.packages("RPostgreSQL")
# install.packages("zoo")
# install.packages("ggplot2")
# install.packages("plotly")


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


# Pacchetto per gestire le date
library("zoo")
library("ggplot2")
library("ggmosaic")
library("plotly")
library("scales")



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




######################################################################################
#################################### AREA 51 #########################################
######################################################################################



t = dbGetQuery(con, "set search_path to ospedale; 
select nome, cognome, data_dia, data_nasc
from paziente p join ricovero r on p.cf = r.paziente 
                join diagnosi d on d.ricovero = r.cod_ric 
where p.data_nasc > d.data_dia and cognome = 'rotella';
") #NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO



# Possibili grafici

# Andamento nuovi pazienti e ricoveri nei mesi
# due linee stesso grafico

# Per ottenere le date degli inserimenti dei nuovi pazienti recupero la data del loro primo ricovero 

nuovi_pazienti = dbGetQuery(con, 
"
set search_path to ospedale;

select to_char(r2.data_i, 'YYYY-MM') as periodo, count(*) as totale        
from (select r.data_i
      from ricovero r left join ricovero r1 on r.data_i < r1.data_i
      where r.paziente = r1.paziente) as r2
group by 1 
order by 1 asc;

")

nuovi_ricoveri = dbGetQuery(con,
"
set search_path to ospedale;

select to_char(r2.data_i, 'YYYY-MM') as periodo, count(*) as totale        
from ricovero r2
group by 1 
order by 1 asc;

")

g_n_pazienti = plot(totale ~ as.yearmon(nuovi_pazienti$periodo, "%Y-%m"), 
                                        nuovi_pazienti, 
                                        type = "l",
                                        xlab = "Anno",
                                        ylab = "Inserimenti"
                                        )



g_n_ricoveri = plot(totale ~ as.yearmon(nuovi_ricoveri$periodo, "%Y-%m"), 
                                        nuovi_ricoveri, 
                                        type = "l",
                                        xlab = "Anno",
                                        ylab = "Inserimenti"
                                        )

overlap <- function(df1, df2){

    plot(df1[,2] ~ as.yearmon(df1[,1], "%Y-%m"), 
                             df1, 
                             type = "l",
                             xlab = "Periodo",
                             ylab = "Inserimenti",
                             col = "red",
                             ylim = c(0,800)
                             )
    lines(df2[,2] ~ as.yearmon(df2[,1], "%Y-%m"), 
                               df2, 
                               type = "l",
                               xlab = "Periodo",
                               ylab = "Inserimenti",
                               col = "blue"
                               )
    legend("topright",
           c("Pazienti", "Ricoveri"),
           fill = c("blue", "red")
           )

}

grafico_1 = overlap(nuovi_ricoveri, nuovi_pazienti)














# Quanti ricoveri in media hanno i pazienti più anziani rispetto a quelli più giovani? sotto 30 e sopra i 60
# Coppie di barre per anno 


giovani = dbGetQuery(con,
"
set search_path to ospedale;

select extract(year from r.data_i) as anno, count(*) as numero
from ricovero r join paziente p on r.paziente = p.cf
where p.data_nasc > '1989-01-01'
group by 1
order by 1 asc;

")

anziani = dbGetQuery(con,
"
set search_path to ospedale;

select extract(year from r.data_i) as anno, count(*) as numero
from ricovero r join paziente p on r.paziente = p.cf
where p.data_nasc < '1959-01-01'
group by 1
order by 1 asc;

")

index = 1;
lista_persone_df <- list()

for(i in 1:length(giovani[,1])){

    tupla <- data.frame(anno = giovani[i,1],
                        eta = "giovani",
                        numero = giovani[i,2])

    lista_persone_df[[index]] <- tupla
    index = index + 1
}


for(i in 1:length(anziani[,1])){

    tupla <- data.frame(anno = anziani[i,1],
                        eta = "anziani",
                        numero = anziani[i,2])

    lista_persone_df[[index]] <- tupla
    index = index + 1
}


persone_df = megabind(lista_persone_df)


p <- ggplot(persone_df , aes(x = anno, y= numero, fill = eta)) + 
       geom_bar(stat="identity", position= position_dodge(), colour ="black") 

p <- p + labs(x = "Periodo", y = "Totale Ricoveri",fill = "Grado d'anzianità") +
         scale_x_continuous(limits = c(2007, 2019.5))
#p <- ggplotly(p)










# Quante diagnosi per tumore vengono fatte ai più giovani (max 30 anni) ogni anno ?
# A lineee anche questo 1 linea <30, 30-60, 60>


fascia_1 = dbGetQuery(con,
"
set search_path to ospedale;

select extract(year from r.data_i) as anno, count(*) as numero
from ricovero r join paziente p on r.paziente = p.cf
where p.data_nasc > '1989-01-01'
group by 1
order by 1 asc;

")



fascia_2 = dbGetQuery(con,
"
set search_path to ospedale;

select extract(year from r.data_i) as anno, count(*) as numero
from ricovero r join paziente p on r.paziente = p.cf
where (p.data_nasc < '1989-01-01' and p.data_nasc > '1959-01-01')
group by 1
order by 1 asc;

")



fascia_3 = dbGetQuery(con,
"
set search_path to ospedale;

select extract(year from r.data_i) as anno, count(*) as numero
from ricovero r join paziente p on r.paziente = p.cf
where p.data_nasc > '1959-01-01'
group by 1
order by 1 asc;

")




index = 1;
lista_persone_df <- list()

for(i in 1:length(fascia_1[,1])){

    tupla <- data.frame(anno = fascia_1[i,1],
                        fascia = "30",
                        numero = fascia_1[i,2])

    lista_persone_df[[index]] <- tupla
    index = index + 1
}

for(i in 1:length(fascia_3[,1])){

    tupla <- data.frame(anno = fascia_3[i,1],
                        fascia = "60",
                        numero = fascia_3[i,2])

    lista_persone_df[[index]] <- tupla
    index = index + 1
}

for(i in 1:length(fascia_2[,1])){

    tupla <- data.frame(anno = fascia_2[i,1],
                        fascia = "30-60",
                        numero = fascia_2[i,2])

    lista_persone_df[[index]] <- tupla
    index = index + 1
}




persone_df = megabind(lista_persone_df)


p <- ggplot(persone_df , aes(x = anno, y= numero, fill= fascia)) + 
       geom_bar(stat="identity", position= position_dodge(), colour ="black") 

p <- p + labs(x = "Periodo", y = "Incidenze Tumorali",fill = "Fascia d'età") +
         scale_x_continuous(limits = c(2007, 2019.5))





















# In quale periodo dell'anno ci sono più ricoveri per influenza? 
# A mosaico colonna per i mesi, riga per gli anni, area per il numero
# Alternativa heatmap



ricoveri = dbGetQuery(con,
"
set search_path to ospedale;

select to_char(r2.data_i, 'YYYY') as anno, to_char(r2.data_i, 'MM') as mese, count(*) as totale        
from ricovero r2
where motivo = 'influenza'
group by 1,2 
order by 1,2 asc;

")

anni <- array()
mesi <- array()
index = 1

for(i in 1:length(ricoveri[,3])){

    for(j in 1:ricoveri[i,3]){
        anni[index] = ricoveri[i,1]
        mesi[index] = ricoveri[i,2]
        index = index +1
    }

}

mosaicplot(table(anni, mesi), 
           main = "Numero di ricoveri per influenza",
           xlab = "Anni",
           ylab = "Mesi"
           )



anni = c("2008":"2019")
mesi = c("1":"12")

tab = matrix(nrow = 12, ncol = 12)
k = 1
for(i in 1:12){
    for(j in 1:12){
        tab[i,j] = ricoveri[k,3]
        k = k+1
    }
}

colnames(tab) = mesi
rownames(tab) = anni
tab = as.table(tab)

image(2008:2019, 1:12,tab, xlab="Anni",ylab="Mesi")










# Quanti giorni di ricovero fanno in totale i pazienti a cui viene diagnosticato un tumore, rispetto alla media dei ricoveri?
# MultiBoxplot (1 per ricoveri solo tumore, 1 per tutti ricoveri)

ric_tumore <- dbGetQuery(con,
"
set search_path to ospedale;

select (r.data_f-r.data_i) as tot_gg
from ricovero r join diagnosi d on d.ricovero = r.cod_ric
where d.cod_pat similar to 'T0[0-9]'
")

ric_totali <- dbGetQuery(con,
"
set search_path to ospedale;

select (r.data_f-r.data_i) as tot_gg
from ricovero r 
")


boxplot(ric_tumore$tot_gg, ric_totali$tot_gg, pch=16, cex=0.2, 
        xlab="Tumori                                                   Tutti")












# Diffusione dei farmaci negli anni, in colonna 10 farmaci più usati? o altro, in riga mesi
# La trasparenza è data dagli usi giornalieri del farmaco che si contano sapendo data inizio e fine terapia prescritta
# scatterplot con trasparenza                           

# Voglio prendere i 10 farmaci più usati e i 10 meno usati e avere per ognuno di questi, in ogni giorno dell'anno
# quante somministrazioni sono state effettuate di quel farmaco 






farm <- dbGetQuery(con,
"
set search_path to ospedale;

select f.nome_comm, to_char(tp.data_i, 'YYYY-MM') as periodo, sum(tp.data_f-tp.data_i) as tot_gg
from farmaco f join terapia t on f.nome_comm = t.farmaco
               join terapia_prescritta tp on tp.terapia = t.cod_ter
group by 1,2
having sum(tp.data_f-tp.data_i) > 0
order by 2,3 desc;
")

farmaci_max <- dbGetQuery(con,
"
set search_path to ospedale;

select f.nome_comm, sum(tp.data_f-tp.data_i) as tot_gg
from farmaco f join terapia t on f.nome_comm = t.farmaco
               join terapia_prescritta tp on tp.terapia = t.cod_ter
group by 1
order by 2 desc;
")

farmaci <- dbGetQuery(con,
"
set search_path to ospedale;

select f.nome_comm, tp.data_i, tp.data_f
from farmaco f join terapia t on f.nome_comm = t.farmaco
               join terapia_prescritta tp on tp.terapia = t.cod_ter
order by 1;

"
)

f_top <- farmaci_max[1:10,]
f_bot <- farmaci_max[(length(farmaci_max[,1])-9):length(farmaci_max[,1]),] 

f_tot <- rbind(f_top, f_bot)

frm <- merge(farmaci, f_tot, by="nome_comm",all.y =FALSE)
frm <- frm[,1:3]

giorni <- seq(min(frm[,2]), max(frm[,2]), by="day")
mesi <- seq(min(frm[,2]), max(frm[,2]), by="month")

#f_tot <- f_tot[,sort(f_tot[,2])]

giusti <- f_tot[,1]

f_tot <- f_tot[,2]



# mat <- matrix(0L, nrow=length(giorni), ncol=length(f_tot[,1]))


# for(giorno in 1:length(giorni)){
    
#     for(farmaco in 1:length(giusti)){

#         for(index in 1:length(frm[,1])){

#             if(giusti[farmaco] == frm[index,1] && giorni[giorno] >= frm[index,2] && giorni[giorno] <= frm[index,3]){
#                 mat[giorno, farmaco] = mat[giorno, farmaco] +1
#             }           
#         }
#     }
# }


mat <- matrix(0L, nrow=length(mesi), ncol=length(f_tot[,1]))


for(mese in 1:length(mesi)){
    
    for(farmaco in 1:length(giusti)){

        for(index in 1:length(frm[,1])){

            if(giusti[farmaco] == frm[index,1] && mesi[mese] >= frm[index,2] && mesi[mese] <= frm[index,3]){
                mat[mese, farmaco] = mat[mese, farmaco] +1
            }           
        }
    }
}



image(1:length(mesi),1:20,mat)




######################################################################################
#################################### AREA 51 #########################################
######################################################################################




#  Disconnessione dal db 
dbDisconnect(con)
