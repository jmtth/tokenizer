SHELL := /bin/bash

MODULE ?= ./deployment/modules/Goodies42.ts
NETWORK ?= localhost

.PHONY: help install compile test clean node deploy-local deploy-sepolia demo

help:
	@echo "Available targets:"
	@echo "  make install         # install npm dependencies"
	@echo "  make compile         # compile contracts"
	@echo "  make test            # run all tests"
	@echo "  make node            # start local hardhat node"
	@echo "  make deploy-local    # deploy with ignition on localhost"
	@echo "  make deploy-sepolia  # deploy with ignition on sepolia"
	@echo "  make clean           # clean hardhat cache/artifacts"
	@echo "  make demo            # run the demo script"

install:
	npm install

compile:
	npx hardhat compile

test:
	npx hardhat test

node:
	npx hardhat node

deploy-local:
	npx hardhat ignition deploy $(MODULE) --network localhost

deploy-sepolia:
	npx hardhat ignition deploy $(MODULE) --network sepolia

demo:
	npx hardhat run code/scripts/demo.js

clean:
	npx hardhat clean
