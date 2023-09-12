from datetime import datetime
import os

TOKEN_ENV_VAR_NAME = "RU19H_TOKEN"

def convert_time(time_str):
    time = time_str.split(':')
    date = datetime.now()
    date = date.replace(hour = int(time[0]), minute = int(time[1]), second = int(time[2]))
    return date

RU_MIDI = convert_time("11:45:00")
RU_SOIR = convert_time("19:00:00")

def get_token():
    return os.environ[TOKEN_ENV_VAR_NAME]

def get_poll_desc():
    time = datetime.now()
    print(time)
    print(RU_MIDI, RU_SOIR)
    if time < RU_MIDI or time > RU_SOIR:
        title = f"RU 11h45 ? Heure actuelle: {time}"
        questions = ['Pharma', 'RUFL', 'RU ENS', 'LDV', 'Non', get_truc_random()]
    else:
        title = f"RU 19h ? Heure actuelle: {time}"
        questions = ['Oui', 'Non', get_truc_random()]
    return title, questions

def get_truc_random():
    return 'pala'
