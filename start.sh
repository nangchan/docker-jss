#!/bin/bash

__start() {
# clone repo and install npm packages
cd ~
git clone https://github.com/Sitecore/jss.git
cd ~/jss/samples/react
npm install
}

# Call all functions
__start
