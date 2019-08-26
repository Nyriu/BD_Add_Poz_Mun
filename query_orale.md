

Se si cerca un paziente per nome allora conviene creare un indice, il costo nel caso con indice e' notevolmente ridotto. in tempo si guadagna 1 ms circa

explain analyze select cf, nome, cognome, data_nasc from paziente where nome = 'tino';
