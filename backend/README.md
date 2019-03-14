This is the main codebase of the backend system. 
It is developed using python programming language 
and Flask micro web framework.

## API Documentation

Api documentation is available [here](https://swe599onur.docs.apiary.io/)


## Running

### Development 

#### Option 1: With Docker

@TODO

#### Option 2: With virtual env

<b>Step 0 *optional but recommended</b><br>
This project is developed with python 3.7 but it should work with 3.5+<br>
[pyenv](https://github.com/pyenv/pyenv) is a useful tool for for switching
between python versions easily on a per-project basis.<br>
After installation run 
```
$ pyenv install 3.7.0
$ cd /path/to/project
$ pyenv local 3.7.0

# verify python version
$ python --version
Python 3.7.0
```

<b>Step 1</b><br>
Clone this repository
```
$ git clone https://github.com/tokonu/SWE599.git
$ cd backend
```
<b>Step 2</b><br>
Set up virtual environment and install dependencies
```
$ python -m venv venv

# we will need environment variable to run flask later
# not necessary but makes life easier 
$ echo "export FLASK_APP=flaskcli" >> venv/bin/activate

$ source venv/bin/activate
$ pip install --upgrade pip
$ pip install -r requirements.txt
```

* Commands on the following two steps are defined in flaskcli.py<br>

<b>Step 3</b><br>
Run tests

```
$ flask test
```

<b>Step 4</b><br>
Create database
```
$ flask db create
```

<b>Step 5 (i)</b><br>
Run using command line
```
$ flask run
```
<b>Step 5 (ii)</b><br>
Run using pycharm<br>
Some configuration should be done before.
Navigate to<br>
Preferences->Project->ProjectInterpreter<br>
Click gear icon next to Project Interpreter field and click add.
Select existing environment and choose {PROJECT_DIR}/venv/bin/python<br>
Save and apply.<br>
[Then Follow this step](http://flask.pocoo.org/docs/1.0/cli/#pycharm-integration)
### Production

@todo