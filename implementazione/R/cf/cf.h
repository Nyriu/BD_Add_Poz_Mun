/*============================================================================
 * Name        : cf.h
 * Version     : 1.3
 * Since       : 2004
 * Author      : Alberto Realis-Luc <alberto.realisluc@gmail.com>
 * Web         : http://www.alus.it/pubs/CodiceFiscale
 * Copyright   : © 2004 Alberto Realis-Luc
 * License     : GNU GPL
 * Last change : 30/1/2013
 * Description : Header of cf module to generate Italian fiscal codes
 *============================================================================*/

#include <stdio.h>
#include <string.h>

#define MAXP 30 /*numero massimo caratteri del comune*/

typedef struct comunale {
	char *nome;
	char alfa;
	int num;
	struct comunale *nx;
}*comune;

int carica(char *filecomuni);
comune ricerca(char *nomeComune);
char *cf(char *cog, char *nome, int gg, int mm, int aaaa, char sex, comune comuneNascita);
void pulisci(void);
