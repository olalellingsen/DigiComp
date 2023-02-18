#!/usr/bin/python
# -*- coding: latin-1 -*-

"""
OSC server and client, for communicating with Csound

@author: Øyvind Brandtsegg
@contact: obrandts@gmail.com
@license: GPL
"""

from pythonosc.udp_client import SimpleUDPClient
from pythonosc import dispatcher
from pythonosc.osc_server import AsyncIOOSCUDPServer
import signal
import asyncio
stop_event = asyncio.Event()

receive_address = '127.0.0.1', 9901
send_address = '127.0.0.1', 9999

def init_osc_client():
    '''Initialize the OSC client'''
    global client
    ip,port = send_address
    client = SimpleUDPClient(ip, port)
    print("running osc client at ", send_address)
    
def sendOSC(addr, value):
    '''Send an OSC message'''
    client.send_message(addr, value)    

async def loop():
    '''Main loop'''
    while not stop_event.is_set():
        await asyncio.sleep(1)

def inner_ctrl_c_signal_handler(sig, frame):
    '''
    Function that gets called when the user issues a
    keyboard interrupt (ctrl+c) to stop the server
    '''
    print("Ctrl+C ...")
    stop_event.set()
    
async def run_osc_server():
    '''Start the OSC server'''
    ip,port = receive_address
    server = AsyncIOOSCUDPServer((ip,port), dispatcher, asyncio.get_event_loop())
    transport, protocol = await server.create_serve_endpoint()  # Create datagram endpoint and start serving
    print("running osc server at ", receive_address)
    await loop()  # Enter main loop of program
    transport.close()  # Clean up serve endpoint
    print("osc server closed")
    
signal.signal(signal.SIGINT, inner_ctrl_c_signal_handler)
init_osc_client()
dispatcher = dispatcher.Dispatcher()


