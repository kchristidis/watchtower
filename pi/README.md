# scm-scripts

## Author:
Spencer Hitchins (jshitchi@ncsu.edu)

## Python Version: 
python-2.7.9

## System Dependencies:
Adafruit BMP085 Python Library
pip
postgresql
python-opencv
RPi.GPIO
virtualenv

## Getting Started:

#### Enter scm-scripts directory:
cd scm-scripts

#### Create and activate virtualenv:
virtualenv venv
source venv/bin/activate

#### Install dependencies:
pip install -r requirements.pip

#### Create secrets file:
touch secrets.py

#### Copy example config file to config file location (descriptions of how to change this file are included in the example file):
cp conf/sensors.ini.example conf/sensors.ini

#### Run people counting script in background:
python people_counter.py &

#### Run data capture script
python capture_data.py
