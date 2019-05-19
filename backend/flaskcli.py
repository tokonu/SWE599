from server import create_app
from flask.cli import AppGroup
from server import db

app = create_app("development")


'''
Test
'''


@app.cli.command("test")
def test():
    import tests
    tests.run()


'''
Database 
'''

db_cli = AppGroup('db')


@db_cli.command('create')
def create_db():
    print("creating db")
    db.create_all()


@db_cli.command('drop')
def create_db():
    print("dropping db")
    db.drop_all()


app.cli.add_command(db_cli)

