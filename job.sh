#!/bin/bash

#SBATCH --chdir=/scratch/nas/4/norma/test_script
#SBATCH --job-name="test"
#SBATCH --output=/scratch/nas/4/norma/.log/stdout-%j.out
#SBATCH --error=/scratch/nas/4/norma/.log/stderr-%j.out
#SBATCH --wait-all-nodes=1
#sun --pty /bin/bash
# Enviroment variables
PYTHON="/scratch/nas/4/norma/venv/bin/python"
SERVER_SYNC_FILE=".sync/server_ready.out"
TARGET="datasets"

# Lunch server on host node
$PYTHON -m ppcnn --server &
SERVER_PID="$!"

# Wait for server sync file
echo "Waiting for server"
SERVER_INIT=0
while [ $SERVER_INIT -eq 0 ]
do
    if test -f "$SERVER_SYNC_FILE"; then
        SERVER_INIT=1
    fi
    sleep 1
done

# Read server address from file
SERVER_ADDRESS=`cat $SERVER_SYNC_FILE`

# Run client on guest nodes
echo "Running clients"
CLIENT_PIDS=""
for node in `scontrol show hostnames $SLURM_JOB_NODELIST`; do
    if [ "$HOSTNAME" != "$node" ] ; then
        srun --nodes=1 --nodelist $node --ntasks=1 $PYTHON -m ppcnn --address=$SERVER_ADDRESS --target=$TARGET &
        CLIENT_PIDS="$CLIENT_PIDS $!"
    fi
done

# Wait for all clients to have finished
echo "Waiting for clients"
wait $CLIENT_PIDS

# Delete sync file
rm $SERVER_SYNC_FILE

# Kill server
kill $SERVER_PID