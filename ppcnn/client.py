import socket
import pickle
from ppcnn import coms

def run(address, target):
    print(f'Running client to {address} with target {target}')
    clientsocket = socket.socket()
    clientsocket.connect((address, coms.PORT))
    sock = coms.CustomSocket(clientsocket)
    
    sock.send_str(socket.gethostname())