This is the main codebase of the backend system. 
It is developed using python programming language 
and Flask micro web framework.

## API Documentation

Api documentation is available [here](https://swe599onur.docs.apiary.io/)


## Running

### Development 

#### Option 1: With Docker

@todo

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

Warning: This project contains some bad practices and is not meant to be used in production. 
The sole purpose is to showcase the project. An incomplete list of what needs to be fixed:
1. Do not commit any secret to version control
2. Do not commit any key-pair to version control
3. Do not use sqlite in production
4. If you ignore #3 at least do not create db file in a docker container, containers should be stateless.
5. Separate your socket and restful api servers.
6. Use https

<b>Step 1</b><br>
Launch an Ubuntu 18 instance in aws and connect to your instance
```
$ ssh -i /path/to/key-pair.pem ubuntu@dns-name 
```
<b>Step 2</b><br>
Install Docker
```
$ sudo apt update
$ sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
$ sudo apt update
$ apt-cache policy docker-ce
$ sudo apt install docker-ce -y
$ sudo usermod -aG docker ${USER}
```
Log out of the server and log back in to apply new permissions.

<b>Step 3</b><br>
Clone git repo

```
$ git clone https://github.com/tokonu/SWE599.git
$ cd SWE599/backend
```
<b>Step 4</b><br>
Build and run docker container
``` 
$ docker build --tag=swe .
$ docker run -d -p 80:5000 swe
```