This repo is inspired https://github.com/clutroth/dockerpi3.

Create a virtual pi 3 for development purposes. 

To build all the docker stuff run ./build 
Then ./run.sh

The raspbian image will at $HOME/dockerpi3_image

Do some ansible stuff on the virtual pi.

ansible-playbook  ansible/site.yml -i ansible/inventory.yml


