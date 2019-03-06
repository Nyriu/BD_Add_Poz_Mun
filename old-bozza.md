# Relazione Basi di Dati aa2018/2019

Addis, Munini, Poz

## Requisiti e specifiche

NB come se avessimo analizzato già
**************** il seguente insieme di informazioni riguardanti un sistema per la gestione delle diagnosi e
delle terapie dei pazienti ricoverati in un dato ospedale.
* Di ogni ricovero, il sistema deve memorizzare il codice univoco, il nome della divisione ospedaliera (Cardiologia,
Reumatologia, Ortopedia, ), il paziente ricoverato, le date di inizio e fine del ricovero e il motivo
principale del ricovero.
* Di ogni paziente, il sistema deve memorizzare il codice sanitario (univoco), il cognome, il nome, la data
di nascita, il luogo di nascita e la provincia di residenza. Per i pazienti residenti fuori regione, vengono
memorizzati anche il nome della ULSS e la regione di appartenenza.
* Di ogni diagnosi effettuata durante il ricovero del paziente, sono memorizzati la patologia diagnosticata,
col suo codice ICD10 (classificazione internazionale delle patologie) e l’indicazione della sua gravit`a (grave:
si/no), la data e il nome e cognome del medico che ha effettuato la diagnosi.
* Nella base di dati si tiene traccia delle terapie prescritte ai pazienti durante il ricovero. Di ogni terapia, si
memorizzano il farmaco prescritto, la dose giornaliera, le date di inizio e di fine della prescrizione, la modalit`a
di somministrazione ed il medico che ha prescritto la terapia.
* Di ogni farmaco sono memorizzati il nome commerciale (univoco), l’azienda produttrice, il nome e la quantit`a
dei principi attivi contenuti e la dose giornaliera raccomandata.
* Si tiene, infine, traccia delle diagnosi che hanno motivato le terapie. In particolare, ogni terapia `e prescritta
al fine di curare una o pi`u patologie diagnosticate. Pu`o capitare anche che una nuova patologia (registrata
come nuova diagnosi) sia causata, come effetto collaterale, da una terapia precedentemente prescritta. Tale
legame causa-effetto va registrato nella base di dati.


## Progettazione concettuale

Dai requisiti elencati è possibile identificare le seguenti entità, una per ciascuno dei requisiti.

**NOTA BENE:::::: da convertire in diagramma entità con bolle attributi senza relazioni

* Ricovero
  * codice univoco, costituisce una chiave
  * nome della divisione ospedaliera 
  * paziente ricoverato
  * data di inizio ricovero
  * data di fine ricovero
  * motivo principale del ricovero
  
* Paziente
  * codice fiscale, costituisce una chiave
  * cognome
  * nome
  * data di nascita
  * luogo di nascita
  * provincia di residenza
  * indicazione se è fuori regione
      * nome ULSS
      * regione appartenza

* Diagnosi 
  * patalogia
  * codice ICD10 patologia
  * gravità patologia (si/no)
  * data
  * medico curante

* Terapia
  * farmaco
  * dose giornaliera
  * data inizio prescrizione
  * data fine prescrizione
  * modalità somministrazione
  * medico prescrivente

* Farmaco 
  * nome commerciale
  * azienda produttrice
  * nome principi attivi
  * quantità principi attivi
  
* Un tipo di entità RICOVERO con attributi Codice univoco, Nome della divisione ospedaliera, Paziente ricoverato, Data di inizio ricovero, Data di fine ricovero, Motivo principale del ricovero.
Si può specificare che il codice univoco sia un attributo chiave.

* Un tipo di entità PAZIENTE con attributo Codice fiscale, Cognome, Nome, Data di nascita, Luogo di nascita, Provincia di residenza, Indicazione se è fuori regione, Nome ULSS, Regione appartenza.
Il codice fiscale, essendo univoco, può essere utilizzato come attributo chiave. 

* Un tipo di entità DIAGNOSI con attributi Patalogia, Codice ICD10 patologia, Gravità patologia, Data, Medico curante.

* Un tipo di entità TERAPIA con attributi Farmaco, Dose giornaliera, Data inizio prescrizione, Data fine prescrizione, Modalità somministrazione, Medico prescrivente.

* Un tipo di entità FARMACO con attributi Nome commerciale, Azienda produttrice, Nome principi attivi, Quantità principi attivi.

Dai requisiti specifichiamo i seguenti tipi di relazione

* (DI oppure RIFERITO A)UUUUA una relazione uno a molti tra PAZIENTE e RICOVERO. Un RICOVERO è UUUUATO da uno ed un solo PAZIENTE. Un PAZIENTE UUUUA almeno un RICOVERO e assumiamo che un PAZIENTE possa UUUUARE più ricoveri.

* EFFETTUATA_DURANTE una relazione uno a molti tra RICOVERO e DIAGNOSI. Durante un RICOVERO possono essere effettute più diagnosi, ma assumiamo che possa esistere un RICOVERO durante il quale, inizialmente, non venga effettutata una DIAGNOSI. Una DIAGNOSI è in relazione con uno e un solo RICOVERO.

* DIAGNOSTICA una relazione molti a molti tra DIAGNOSI e PATOLOGIA. Assumiamo che una DIAGNOSI può diagnosticare nessuna PATOLOGIA o molteplici patologie. Assumiamo che esista nell'ospedale un archivio di patologie non diagnosticate e che una PATOLOGIA possa essere diagnostica da più diagnosi.

* PRESCRITTA_DURANTE una relazione uno a molti tra RICOVERO e TERAPIA. Durante un RICOVERO possono essere prescritte più terapie, ma assumiamo che possa esistere un RICOVERO durante il quale, inizialmente, non venga prescritta una TERAPIA. Una TERAPIA è in relazione con uno e un solo RICOVERO.

* SOMMINISTRATO_DURANTE una relazione uno a molti tra FARMACO e TERAPIA. Assumiamo che esista nell'ospedale un archivio di farmaci e che un FARMACO possa essere SOMMINISTRATO_DURANTE più terapie. Durante una TERAPIA viene somministrato uno ed un solo FARMACO.

* CURA una relazione molti a molti tra TERAPIA e PATOLOGIA. Assumiamo che una TERAPIA possa curare più PATOLOGIE e che venga prescritta in presenza di almeno una di queste. Una PATOLOGIA può essere curata da più TERAPIE. Assumiamo che a un paziente possa essere stata diagnosticata una PATOLOGIA ma non ancora prescritta una TERAPIA.

* EFFETTO_COLLATERALE è una relazione ternaria tra DIAGNOSI, PATOLOGIA e TERAPIA. Ipotizziamo che la TERAPIA potrebbe non avere effetti collaterali oppure averne molteplici, che la PATOLOGIA possa essere causata da più TERAPIE o da nessuna ed infine che la DIAGNOSI stabilisca collegamenti tra TERAPIE e PATOLOGIE.
 
**NOTA BENE:::::: SCHEMA COMPLETO PRIMA BOZZA ER
 

### Raffinamenti Top-Down


 




DOPO

Assunzione

* L'entità ricovero ha un attributo paziente, assumiamo che 

