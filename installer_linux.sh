#!/bin/bash
echo "Este instalador aún no está terminado"

git_origin="https://github.com/elcaza/git_backdoor.git"

sudo apt install git
mdkir ~/$program_name
cd ~/$program_name
git clone $git_origin
