# install.packages("RPostgreSQL")
library("RPostgreSQL")

drv <- dbDriver("PostgreSQL")

cred = read.csv('~/Documents/Uni/TerzoAnno/Lab_DB/SQL_Stuff/SQL.txt')
con <- dbConnect(drv, 
                 dbname  =as.character(cred[['dbname'  ]]),
                 host    =as.character(cred[['host'    ]]),
                 port    =as.character(cred[['port'    ]]),
                 user    =as.character(cred[['user'    ]]),
                 password=as.character(cred[['password']])
                 )

dbGetQuery(con, "set search_path to ospedale;")

dbGetQuery(con, "select * from paziente;")

pazienti = read.csv('../popoliCSV/pazienti.csv')
dbWriteTable(con, 
             name="paziente",
             value=pazienti,
             append=T
             )











dbDisconnect(con)
