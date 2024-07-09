import sqlite3
import pickle
import cmd
import sys
import os
import argparse
import csv
import webbrowser


class QL(cmd.Cmd):
    conn = sqlite3.connect('QL.db')
    c = conn.cursor()
    c.execute('''DROP TABLE IF EXISTS users''')
    c.execute('''CREATE TABLE IF NOT EXISTS users
    (id integer, user text, name text, logo text, home text, color integer, section integer, prompt text)''')

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
            conn.commit()

    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--path', required=False, action='store_true',
                        help='View the path of the given command')
    parser.add_argument('-d', '--description', required=False, action='store_true',
                        help='View description of the given command')

    def __init__(self):
        super().__init__()
        self.next_uid = self.unpickle_ql()
        self.file = None
        self.user = os.getenv('USERNAME')
        self.check_for_user(self.user)
        QL.c.execute('SELECT name FROM paths')
        paths = [row[0] for row in QL.c.fetchall()]
        for path_name in paths:
            setattr(QL, f'do_{path_name}', self.generate_do_function(path_name))
            QL.conn.commit()

    @staticmethod
    def generate_do_function(path_name):
        def do_path_action(self, *arg):
            """Open or display description for the file"""
            QL.c.execute('SELECT path, description, method FROM paths WHERE name=?', (path_name,))
            result = QL.c.fetchone()
            if result:
                file_path, description, method = result
                if arg != ('',):
                    args = QL.parser.parse_args(arg)
                    if args.path:
                        print(f'File Path: {file_path}')
                    elif args.description:
                        print(f'Description: {description}')
                else:
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
        return do_path_action

    def check_for_user(self, user):
        QL.c.execute('SELECT user FROM users WHERE user=?', (user,))
        if QL.c.fetchone():
            print(f"--- Found user: {self.user} ---")
        else:
            print(f"--- User not found ---\nadding {self.user}...")
            self.new_user("ethan")
            self.check_for_user(user)

    def new_user(self, name=None, logo=None, home=None, color=None, section=None, prompt=None):
        self.conn.execute('INSERT INTO users (id, user, name, logo, home, color, section, prompt) '
                          'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                          (self.next_uid, self.user, name, logo, home, color, section, prompt))
        self.next_uid += 1
        QL.conn.commit()

    def close(self):
        if self.file:
            self.file.close()
            self.file = None
        os.system('exit')

    def __getstate__(self):
        attributes = self.__dict__.copy()
        del attributes['stdin']
        del attributes['stdout']
        return attributes

    def __setstate__(self, state):
        state['stdin'] = sys.stdin
        state['stdout'] = sys.stdout
        self.__dict__ = state

    def precmd(self, line):
        return line

    def do_exit(self, *arg):
        self.record_state(arg[0])
        ql.conn.close()
        sys.exit()

    def record_state(self, arg):

        def pickle_ql():
            with open('QL.pkl', 'wb') as file:
                print('pickling ql...')
                pickle.dump(self, file)

        with open('QL.pkl', 'rb') as pkl:
            old_ql = pickle.load(pkl)
            if arg == 'True':
                self.next_uid = 1
                pickle_ql()
            elif old_ql.next_uid < self.next_uid:
                pickle_ql()

    @staticmethod
    def unpickle_ql():
        with open('QL.pkl', 'rb') as pkl:
            old_ql = pickle.load(pkl)
            return old_ql.next_uid

    @staticmethod
    def do_view(*args):
        QL.c.execute('SELECT name FROM paths')
        names = QL.c.fetchall()
        for name in names:
            print(name[0], end="\t")
        print()


if __name__ == "__main__":
    ql = QL()
    ql.cmdloop()
