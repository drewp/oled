from fabric.api import env
from subprocess import check_call
import json
env.hosts = ['localhost']

def mos(*args):
    check_call(['../../mos',
                #'--logtostderr',
                '--port',
                #'ws://10.2.0.62/rpc',
                '/dev/ttyUSB0',
            ] + list(args))

def call(method, **kwargs):
    mos('call', method, json.dumps(kwargs))

def push():
    mos('put', 'fs/init.js')
    reboot()

def config():
    mos('put', 'fs/conf0.json')
    reboot()
    
def reboot():
    call('Sys.Reboot')
    
def console():
    mos('console')

def flash():
    mos('build', '--local')
    mos('flash', 'build/fw.zip')
    
