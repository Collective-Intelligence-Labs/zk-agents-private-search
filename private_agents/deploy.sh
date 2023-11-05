PRIVATEKEY="APrivateKey1zkpAXoVC8gAr6QYGDmC2G8s6b4BJbjXVfz19gLcyuLU2XK5"

APPNAME="private_agents"

cd .. && snarkos developer deploy "${APPNAME}.aleo" --private-key "${PRIVATEKEY}" --query "https://vm.aleo.org/api" --path "./${APPNAME}/build/" --broadcast "https://vm.aleo.org/api/testnet3/transaction/broadcast"  --priority-fee 1000 ``
