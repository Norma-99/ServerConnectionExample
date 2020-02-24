import socket
import threading
import pickle
from ppcnn import coms

SERVER_INIT_FILE = '.sync/server_ready.out'

def on_connection(clientsocket):
    sock = coms.CustomSocket(clientsocket)
    address = sock.recv_str()
    print(f'Connection from {address}')


def run():
    print('Starting server')
    serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    serversocket.bind((socket.gethostname(), coms.PORT))
    serversocket.listen(5)
    print('Server listening')
    
    #create file where we will write the ip
    with open(SERVER_INIT_FILE, 'w') as f:
        f.write(socket.gethostname()) 

    while True:
        (clientsocket, _) = serversocket.accept()
        threading.Thread(target=lambda: on_connection(clientsocket), daemon=True).start()