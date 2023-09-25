from datetime import datetime
import os

TOKEN_ENV_VAR_NAME = "RU19H_TOKEN"

def convert_time(time_str):
    time = time_str.split(':')
    date = datetime.now()
    date = date.replace(hour = int(time[0]), minute = int(time[1]), second = int(time[2]))
    return date


def get_token():
    return os.environ[TOKEN_ENV_VAR_NAME]

def get_poll_desc(args):
    time = datetime.now()
    RU_SOIR = convert_time("20:00:00")
    RU_MIDI = convert_time("12:00:00")
    print(time)
    print(RU_MIDI, RU_SOIR)
    if time < RU_MIDI or time > RU_SOIR:
        if len(args) == 0:
            title = "RU 11h30 ?"
        else:
            title = f"RU {args[0]} ?"
        questions = ['Pharma', 'RUFL', 'RU ENS', 'LDV', 'Non', get_truc_random()]
    else:
        if len(args) == 0:
            title = "RU 19h ?"
        else:
            title = f"RU {args[0]} ?"
        questions = ['Oui', 'Non', get_truc_random()]
    return title, questions

def get_truc_random():
    return 'pala'
