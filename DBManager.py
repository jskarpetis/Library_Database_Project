import traceback
from types import TracebackType
import sqlite3
import os.path
import sys 
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

class DBManager:
    """
    A class to represent a Manager of our DB.
    Basic CRUD operation executes here in a dynamic way.

    ...

    Attributes
    ----------
    path : str
        The full name of the DB file with .db at the end

    Methods
    -------
    SELECT(table,data="*",condition="")
        Execute SQL SELECT operation or R operation within given table.
        data represent which data we want to choose from table , default value -> all ("*")
        condition represent the condition to select the given data.

        Example:

            SELECT("Book","*",condition="Book_ID > 4")
            - This will print all fields of Books where Book ID is bigger than 4

    INSERT(table,fields,data)
        Execute SQL INSERT operation or C operation withing given table.
        fields represent the fields of table that we want to add data
        data represent the actual data we want to insert in the given fields

    UPDATE(table,setter,condition)
        Execute SQL UPDATE operation or U operation within given table.
        setter represent the updates(with data) that you want to change
        condition represent in which row we are going to update data

    DELETE(table,condition)
        Execute SQL DELETE operation or D operation within given table.
        condition represent which row or rows we are going to delete

    ErrorInfo(er)
        If an error occurs while CRUD operations this function will print all error info

    save()
        Will save the changes that we did in DB.

    close()
        Will close the connection that we have with DB.
    """

    __DBPath = ""

    def __init__(self,path):

        DBManager.__DBPath=os.path.join(BASE_DIR,path)
        self.connection = sqlite3.connect(DBManager.__DBPath,check_same_thread=False)
        self.cursor = self.connection.cursor()
        
    def SELECT(self,table,data="*",condition=""):
        df = []
        sql = f"SELECT {data} FROM {table} WHERE {condition}" if condition else f"SELECT {data} FROM {table}" 

        self.cursor = self.connection.execute(sql)
        for row in self.cursor:
            df.append(row)
        
        return df
    
    def INSERT(self,table,fields,data):

        try:
            self.connection.execute(f"INSERT INTO {table} {fields} VALUES {data}")

        except sqlite3.Error as er:
            self.ErrorInfo(er)

    def UPDATE(self,table,setter,condition):

        try:
            self.connection.execute(f"UPDATE {table} SET {setter} WHERE {condition}") 

        except sqlite3.Error as er:
            self.ErrorInfo(er)

    def DELETE(self,table,condition):
        
        try:
            self.connection.execute(f"DELETE FROM {table} WHERE {condition}")

        except sqlite3.Error as er:
            self.ErrorInfo(er)

    def ErrorInfo(self,er):

        print('SQLite error: %s' % (' '.join(er.args)))
        print("Exception class is: ", er.__class__)
        print('SQLite traceback: ')
        exc_type, exc_value, exc_tb = sys.exc_info()
        print(traceback.format_exception(exc_type, exc_value, exc_tb))

    def save(self):
        self.connection.commit()

    def close(self):
        self.connection.close()
