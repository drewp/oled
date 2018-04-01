from fabric.api import env
from subprocess import check_call
import json
env.hosts = ['localhost']

def mos(*args):
    check_call(['mos',
                #'--logtostderr',
                '--port',
                #'ws://10.2.0.62/rpc',
                '/dev/ttyUSB0',
            ] + list(args))

def call(method, **kwargs):
    mos('call', method, json.dumps(kwargs))

def push():
    mos('put', 'fs/init.js')
    mos('put', 'fs/img_spin.bin')
    # (no reboot)

def config():
    mos('put', 'fs/conf0.json')
    
def reboot():
    call('Sys.Reboot')
    
def console():
    mos('console')

def flash():
    check_call(['nim', 'compile', '-d:release', 'src/led.nim'])
    for f in ['/usr/lib/nim/nimbase.h']:
        check_call(['cp', f, 'src/nimcache'])
    for f in ['src/nimcache/led.c', 'src/nimcache/stdlib_system.c']:
        txt = open(f).read()
        txt = txt.replace('#define NIM_INTBITS 16', '#define NIM_INTBITS 32')
        open(f, 'w').write(txt)
    open('src/nimcache/main.c', 'w').write('// empty\n')
    mos('build', '--local')
    mos('flash', 'build/fw.zip')
    config()
    push()
    
