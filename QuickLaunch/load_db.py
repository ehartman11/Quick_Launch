import sqlite3
import csv
import webbrowser
import os

conn = sqlite3.connect('QL.db')
c = conn.cursor()
c.execute('''DROP TABLE IF EXISTS paths''')
c.execute('''CREATE TABLE IF NOT EXISTS paths 
    (id INTEGER PRIMARY KEY, name TEXT, path TEXT, description TEXT, method INTEGER)''')

with open('info.txt', 'r') as f:
    f.readline()
    uid = 1
    reader = csv.reader(f, delimiter='|')
    for line in reader:
        c.execute('INSERT INTO paths VALUES (?, ?, ?, ?, ?)',
                  (uid, line[0].strip(), line[1].strip(), line[2].strip(), int(line[3])))
        uid += 1


def do_path_action(path_name):
    """Open or display description for the file"""
    c.execute('SELECT path, description, method FROM paths WHERE name=?', (path_name,))
    result = c.fetchone()
    if result:
        file_path, description, method = result
        print(f'File Path: {file_path} ({type(file_path)})')
        print(f'Description: {description} ({type(description)})')

        if method == 1:
            # Check if the file exists and open it
            if os.path.exists(file_path):
                os.startfile(file_path)
            else:
                print(f'File {path_name} does not exist')
        elif method == 2:
            webbrowser.open(file_path)
    else:
        print(f'File "{path_name}" not found in database')


c.execute('SELECT * FROM paths')
paths = c.fetchall()
for path in paths:
    do_path_action(path[1])

conn.close()
