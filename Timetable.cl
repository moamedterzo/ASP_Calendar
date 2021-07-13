% Definizione insegnamenti (nome, professore, numero totale di ore)
insegnamento(project_management, muzzetto, 14).
insegnamento(fondamenti_ict,pozzato,14).
insegnamento(linguaggi_markup,gena,20).
insegnamento(gestione_qualita,tomatis,10).
insegnamento(ambienti_sviluppo_linguaggi_clientside_web,micalizio,20).

insegnamento(progettazione_grafica,terranova,10).
insegnamento(progettazione_basi_dati,mazzei,20).
insegnamento(strumenti_metodi_interazione_social,giordani,14).
insegnamento(acquisizione_elaborazione_immagini_statiche,zanchetta,14).
insegnamento(accessibilita_usabilita,gena,14).

insegnamento(marketing_digitale,muzzetto,10).
insegnamento(elementi_fotografia,vargiu,10).
insegnamento(risorse_digitali,boiolo,10).
insegnamento(tecnologie_server_side,damiano,20).
insegnamento(tecniche_strumenti_marketing,zanchetta,10).

insegnamento(introduzione_social_media,suppini,14).
insegnamento(acquisizione_elaborazione_suono,valle,10).
insegnamento(acquisizione_elaborazione_immagini_digitali,ghidelli,20).
insegnamento(comunicazione_pubblicitaria,gabardi,14).
insegnamento(semiologia_multimedialita,santangelo,10).

insegnamento(crossmedia,taddeo,20).
insegnamento(grafica_3d,gribaudo,20).
insegnamento(progettazione_mobile_1,pozzato,10).
insegnamento(progettazione_mobile_2,schifanella,10).
insegnamento(gestione_risorse_umane,lombardo,10).

insegnamento(vincoli_giuridici,travostino,10).

% Definizione delle propedeuticità (corso precedente, corso antecedente)
propedeutico(fondamenti_ict, ambienti_sviluppo_linguaggi_clientside_web).
propedeutico(ambienti_sviluppo_linguaggi_clientside_web, progettazione_mobile_1).
propedeutico(progettazione_mobile_1, progettazione_mobile_2).
propedeutico(progettazione_basi_dati, tecnologie_server_side).
propedeutico(linguaggi_markup, ambienti_sviluppo_linguaggi_clientside_web).

propedeutico(project_management, marketing_digitale).
propedeutico(marketing_digitale, tecniche_strumenti_marketing).
propedeutico(project_management, strumenti_metodi_interazione_social).
propedeutico(project_management, progettazione_grafica).
propedeutico(acquisizione_elaborazione_immagini_statiche, elementi_fotografia).

propedeutico(elementi_fotografia, acquisizione_elaborazione_immagini_digitali).
propedeutico(acquisizione_elaborazione_immagini_statiche, grafica_3d).


% La prima lezione dell’insegnamento di destra deve essere successiva alle prime 4 ore di lezione del corso di sinistra
propedeutico_soft(fondamenti_ict, progettazione_basi_dati).
propedeutico_soft(marketing_digitale, introduzione_social_media).
propedeutico_soft(comunicazione_pubblicitaria, gestione_risorse_umane).
propedeutico_soft(tecnologie_server_side, progettazione_mobile_1).


% Definizione delle 24 settimane
settimana(1..24).

% Definizione delle settimane fulltime 
settimana_fulltime(7;16).

% Ordinamento delle settimane fulltime
n_settimana_fulltime(1, S) :- settimana_fulltime(S), not S1 < S : settimana_fulltime(S1). 
n_settimana_fulltime(N + 1, S) :- n_settimana_fulltime(N, S1), settimana_fulltime(S), 
                                  S1 < S, not S2 < S: S1 < S2, settimana_fulltime(S2). 

% Definizione dei giorni per le settimane standard. Coppia(S, G): S è la settimana, G il giorno
giorno(S,5):-settimana(S).
giorno(S,6):-settimana(S).

% Definizione dei giorni per le settimane fulltime. Coppia(S, G): S è la settimana, G il giorno
giorno(S,1):-settimana_fulltime(S).
giorno(S,2):-settimana_fulltime(S).
giorno(S,3):-settimana_fulltime(S).
giorno(S,4):-settimana_fulltime(S).

% Definizione delle ore disponibili in base al giorno (Lunedì-Venerdì 8 ore, Sabato 4 o 5 ore)
orarioGiorno(S, G, 8) :- giorno(S,G), G >= 1, G <=5.
orarioGiorno(S, G, 4); orarioGiorno(S, G, 5) :- giorno(S, G), G = 6.


% Definizione degli slot. slot_assegnato(Corso, Settimana, Giorno, OraInizio, Durata)
% faccio in modo che la fascia oraria non sfori il limite di orario del giorno
0 { slot_assegnato(C,S,G,O,D) : O=1..Limite-1, D=2..4, O + D <= Limite + 1 } 1 :- insegnamento(C,_,_), orarioGiorno(S, G, Limite).

% Il primo giorno nelle prime due ore c'è la presentazione del master
slot_assegnato(presentazione_master, 1, 5, 1, 2).

% Definizione dei due recuperi delle lezioni che durano due ore ciascuno
2 { slot_assegnato(recupero_lezioni, S, G, 1, 2) : orarioGiorno(S, G, _) } 2.

% Vincolo che fa in modo che la somma degli slot assegnati ad un corso sia uguale al totale delle ore del corso stessp
:- insegnamento(C,_,Tot), not Tot = #sum{ D, S, G  : slot_assegnato(C,S,G,O,D)}.


% Regola di inferenza utilizzata per ridurre l'output del grounding
inf_propedeutico(C1, C2) :- propedeutico(C1, C2).
inf_propedeutico(C1, C3) :- inf_propedeutico(C1, C2), inf_propedeutico(C2, C3).

% Vincolo che fa si che non ci siano due corsi che si sovrappongano.
% Se due corsi sono propedeutici, non è necessario definire alcuni vincoli perché già definiti altrove
:-  slot_assegnato(C1, S, G, O1, D1), 
    slot_assegnato(C2, S, G, O2, D2), 
    not inf_propedeutico(C1, C2),
    not inf_propedeutico(C2, C1),
    C1 != C2,
    O1 < O2,
    O1 + D1 > O2.

% Questo vincolo fa si che due corsi propedeutici non si sovrappongano nello stesso giorno
:-  slot_assegnato(C1, S, G, O1, D1), 
    slot_assegnato(C2, S, G, O2, D2), 
    propedeutico(C1, C2),
    C1 != C2,
    O1 < O2,
    O1 + D1 > O2.

% Questo vincolo fa si che due slot non inizino nella stessa ora
:-  slot_assegnato(C1, S, G, O, _), 
    slot_assegnato(C2, S, G, O, _), 
    C1 < C2. 


% Predicato che permette di determinare i professori
professore(Professore) :- insegnamento(_, Professore, _).

% Si specifica che un professore in una specifica giornata non deve insegnare più di 4 ore
:- professore(Professore), orarioGiorno(Week, Day, _), 
   5 #sum{D, C : insegnamento(C, Professore, _), slot_assegnato(C, Week, Day,_, D) }.


% Vincoli per propedeuticità (il corso C1 per non soddisfare la propedeuticità deve avere uno slot successivo ad uno slot assegnato a C2)
non_soddisfa_propedeutico(C1, C2) :- propedeutico(C1, C2),
                                    S1 > S2, 
                                    slot_assegnato(C1, S1, _, _, _), slot_assegnato(C2, S2, _, _, _).

non_soddisfa_propedeutico(C1, C2) :-propedeutico(C1, C2),
                                    G1 > G2, 
                                    slot_assegnato(C1, S, G1, _, _), slot_assegnato(C2, S, G2, _, _).

non_soddisfa_propedeutico(C1, C2) :- propedeutico(C1, C2),
                                    O1 > O2, 
                                    slot_assegnato(C1, S, G, O1, _), slot_assegnato(C2, S, G, O2, _).

:- non_soddisfa_propedeutico(C1, C2).


% La prima ora dell’insegnamento "Accessibilità e usabilita" deve essere inferiore all’ultima ora dell’insegnamento "Linguaggi markup"
% se non riesco a dimostrare che esiste uno slot per linguaggi markup che è maggiore di accessibilità usabilità, allora il vincolo non è soddisfatto
lezione_successiva(linguaggi_markup, accessibilita_usabilita) :- 
   S1 > S2, 
   slot_assegnato(linguaggi_markup, S1, _, _, _), slot_assegnato(accessibilita_usabilita, S2, _, _, _).

lezione_successiva(linguaggi_markup, accessibilita_usabilita) :- 
   G1 > G2, 
   slot_assegnato(linguaggi_markup, S, G1, _, _), slot_assegnato(accessibilita_usabilita, S, G2, _, _).

lezione_successiva(linguaggi_markup, accessibilita_usabilita) :- 
    O1 > O2, 
   slot_assegnato(linguaggi_markup, S, G, O1, _), slot_assegnato(accessibilita_usabilita, S, G, O2, _).

:- insegnamento(linguaggi_markup, _, _), insegnamento(accessibilita_usabilita, _, _), not lezione_successiva(linguaggi_markup, accessibilita_usabilita).


% L'insegnamento Project Management deve finire entro la prima settimana fulltime.
% Se esiste uno slot con una settimana superiore alla prima fulltime, allora il vincolo non è soddisfatto
:- slot_assegnato(project_management, Week, _, _,_), n_settimana_fulltime(1, N), Week > N.



% La prima lezione degli insegnamenti "Crossmedia: articolazione delle scritture multimediali"
% e "Introduzione al social media management" devono essere collocate nella seconda settimana full-time
:- n_settimana_fulltime(2, N), slot_assegnato(crossmedia, Week, _, _, _), Week < N.
:- n_settimana_fulltime(2, N), not slot_assegnato(crossmedia, N, _, _, _).

:- n_settimana_fulltime(2, N), slot_assegnato(introduzione_social_media, Week, _, _,_), Week < N.
:- n_settimana_fulltime(2, N), not slot_assegnato(introduzione_social_media, N, _, _,_).

% La distanza fra l’ultima lezione di "Progettazione e sviluppo di applicazioni web su dispositivi mobile I"
%  e la prima di "Progettazione e sviluppo di applicazioni web su dispositivi mobile II" non deve superare le due settimane.
:- slot_assegnato(progettazione_mobile_2, Week2, _, _,_), 
    not Week2 - Week1 <= 2 : slot_assegnato(progettazione_mobile_1, Week1, _, _,_).

% La distanza tra la prima e l’ultima lezione di ciascun insegnamento non deve superare le 6 settimane
:- insegnamento(C, _, _), 
    slot_assegnato(C, FirstWeek, _, _,_), 
    slot_assegnato(C, LastWeek, _, _,_), 
    LastWeek - FirstWeek > 6.

% Vincoli per la propedeuticità cosidetta "soft"
% I tre predicati qui di seguito sono veri quando il corso C1 contiene uno slot che è precedente a tutti gli slot del corso C2
% I predicati fanno riferimento ad un particolare giorno, l'orario è stato incluso solo per una questione tecnica (velocizzare il processo di risoluzione)
soddisfaPropedeuticoSoftWeek(C1, C2, Week, Day, Hour):-propedeutico_soft(C1, C2),
                                                       slot_assegnato(C1, Week, Day, Hour, _),
                                                       not Week2 <= Week : slot_assegnato(C2, Week2, _ ,_ ,_).

soddisfaPropedeuticoSoftDay(C1, C2, Week, Day, Hour):- propedeutico_soft(C1, C2), 
                                        slot_assegnato(C1, Week, Day, Hour, _),
                                        not Day2 <= Day : slot_assegnato(C2, Week, Day2 ,_ ,_).

soddisfaPropedeuticoSoftHour(C1, C2, Week, Day, Hour):- propedeutico_soft(C1, C2), 
                                        slot_assegnato(C1, Week, Day, Hour, _),
                                        not Hour2 < Hour : slot_assegnato(C2, Week, Day, Hour2 ,_).

% Questo predicato è vero se il corso C1 possiede uno slot di 4 ore precedente a tutti gli slot del corso C2
soddisfaPropedeuticoSoft4Ore(C1, C2) :- propedeutico_soft(C1, C2), 
                                    slot_assegnato(C1, Week, Day, Hour, 4),  
                                    soddisfaPropedeuticoSoftWeek(C1, C2, Week, Day, Hour),
                                    soddisfaPropedeuticoSoftDay(C1, C2, Week, Day, Hour),
                                    soddisfaPropedeuticoSoftHour(C1, C2, Week, Day, Hour).

% Questo predicato è vero se il corso C1 possiede uno slot di 2 o 3 ore precedente a tutti gli slot del corso C2
% Dato che bisogna effettuare il conteggio degli slot, è necessario includere in questo predicato il giorno e la settimana
soddisfaPropedeuticoSoftDaily2o3Ore(C1, C2, Week, Day) :- propedeutico_soft(C1, C2), 
                                                    slot_assegnato(C1, Week, Day, Hour, 2),  
                                                    soddisfaPropedeuticoSoftWeek(C1, C2, Week, Day, Hour),
                                                    soddisfaPropedeuticoSoftDay(C1, C2, Week, Day, Hour),
                                                    soddisfaPropedeuticoSoftHour(C1, C2, Week, Day, Hour).

soddisfaPropedeuticoSoftDaily2o3Ore(C1, C2, Week, Day) :- propedeutico_soft(C1, C2), 
                                                    slot_assegnato(C1, Week, Day, Hour, 3),  
                                                    soddisfaPropedeuticoSoftWeek(C1, C2, Week, Day, Hour),
                                                    soddisfaPropedeuticoSoftDay(C1, C2, Week, Day, Hour),
                                                    soddisfaPropedeuticoSoftHour(C1, C2, Week, Day, Hour).

% Questo predicato è vero se il corso C1 possiede almeno due slot di 2 o 3 ore precedenti a tutti gli slot del corso C2
soddisfaPropedeuticoSoft2o3Ore(C1, C2) :- propedeutico_soft(C1, C2), 2 { soddisfaPropedeuticoSoftDaily2o3Ore(C1, C2, Week, Day)  }.

% Il vincolo indica che è necessario che ci sia o uno slot da 4 ore oppure 2 slot da 2/3 ore
:- propedeutico_soft(C1, C2), not soddisfaPropedeuticoSoft4Ore(C1, C2), not soddisfaPropedeuticoSoft2o3Ore(C1, C2).


% Per la visualizzazione del calendario si definisce un predicato che allo slot aggiunge anche 
% il nome del professore, se presente
slot_completo(C,S,G,O,D, P) :- slot_assegnato(C,S,G,O,D), insegnamento(C, P ,_).
slot_completo(C,S,G,O,D, nessuno) :- slot_assegnato(C,S,G,O,D), not insegnamento(C, _ ,_).

#show slot_completo/6.
