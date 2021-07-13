# Comando da fornire per eseguire clingo formattando l'output: 
# clingo timetable.cl --outf=2 | python Timetable.py

import json
import operator
import sys
import tkinter.ttk
from tkinter import *


# carica e analizza i dati json forniti da clingo
parsed_input = json.load(sys.stdin)

# ottengo i dati dal JSON di clingo
print(parsed_input['Solver'])
print(parsed_input['Input'])
print(parsed_input['Result'])
print( parsed_input['Models'])
print(parsed_input['Calls'])
print(parsed_input['Time'])
call = parsed_input['Call']

print('Generating timetable...')

# ottengo i predicati
predicate_elements = call[0]['Witnesses'][0]['Value']

# creo un dizionario che raggruppa i predicati per settimana e giorno
dict_settimane = {}
for element in predicate_elements:

	# ottengo i valori del predicato
	element = element.replace('slot_completo(', '')
	element = element.replace(')', '')

	splitted_element = element.split(',')

	settimana = int(splitted_element[1])
	giorno = int(splitted_element[2])

	orario = "Da " + splitted_element[3] + " a " + str((int(splitted_element[3]) - 1 + int(splitted_element[4])))
	professore = splitted_element[5]

	# aggiungo valori al dizionario
	if settimana not in dict_settimane:
		dict_settimane[settimana] = {}
	if giorno not in dict_settimane[settimana]:
		dict_settimane[settimana][giorno] = []

	# ora inizio, corso, orario, professore
	dict_settimane[settimana][giorno].append([int(splitted_element[3]), splitted_element[0], orario, professore])

# effettuo la print dei valori formattati e organizzati per settimane e giorni
print ()
for settimana in sorted(dict_settimane):

	print("-- SETTIMANA " + str(settimana) + " --")

	for giorno in sorted(dict_settimane[settimana]):

		# print giorno
		giorno_str = None
		if(giorno == 1):
			giorno_str = 'Lunedì'
		elif (giorno == 2):
			giorno_str = 'Martedì'
		elif (giorno == 3):
			giorno_str = 'Mercoledì'
		elif (giorno == 4):
			giorno_str = 'Giovedì'
		elif (giorno == 5):
			giorno_str = 'Venerdì'
		elif (giorno == 6):
			giorno_str = 'Sabato'

		print(giorno_str)

		# print degli slot ordinati per orario
		for lezione in sorted(dict_settimane[settimana][giorno], key=lambda x: x[0]):
			print("\t"  + lezione[2] + "\t" + lezione[3] + "\t " + lezione[1])

		print()
