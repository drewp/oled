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
    check_call(['nim-0.18.0/bin/nim', 'compile',
                '--cpu:arm',
                '--os:standalone',
                '--deadCodeElim:on',
                # --gc:refc|v2|markAndSweep|boehm|go|none|regions
                '--gc:stack',
                '--compileOnly',
                '--noMain',
                '--verbosity:2',
                '-d:release',
                '-d:StandaloneHeapSize=1024',
                'src/led.nim'])
    for f in ['nim-0.18.0/lib/nimbase.h']:
        check_call(['cp', f, 'src/nimcache'])
    open('src/nimcache/main.c', 'w').write('// empty\n')
    mos('build', '--local')
    mos('flash', 'build/fw.zip')
    config()
    push()
    
def test(mod):
    check_call(['nim-0.18.0/bin/nim', 'c',
                '--hint[Conf]:off',
                '--hint[Processing]:off',
                '-d:release',
                '--gc:stack',
                '--deadCodeElim:on',
                '-r', 'src/%s_test' % mod,
                '%s::' % mod])
    check_call(['indent', '-l150', 'src/nimcache/%s.c' % mod])
    

def test_animated_strip():
    test('animated_strip')
    
def test_images():
    test('images')
