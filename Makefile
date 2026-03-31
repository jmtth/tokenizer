SHELL := /bin/bash

MODULE ?= ./deployment/ignition/modules/Goodies42Core.ts
NETWORK ?= localhost

.PHONY: help install compile test clean node deploy-local deploy-sepolia deploy-core-local deploy-core-sepolia deploy-bonus-local deploy-bonus-sepolia demo

help:
	@echo "Available targets:"
	@echo "  make install         # install npm dependencies"
	@echo "  make compile         # compile contracts"
	@echo "  make test            # run all tests"
	@echo "  make node            # start local hardhat node"
	@echo "  make deploy-local    # deploy with ignition on localhost"
	@echo "  make deploy-sepolia  # deploy with ignition on sepolia"
	@echo "  make deploy-core-local   # deploy Goodies42 + Goodies42Shop on localhost"
	@echo "  make deploy-core-sepolia # deploy Goodies42 + Goodies42Shop on sepolia"
	@echo "  make deploy-bonus-local  # deploy Goodies42Management (multisig) on localhost"
	@echo "  make deploy-bonus-sepolia# deploy Goodies42Management (multisig) on sepolia"
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

deploy-core-local:
	npx hardhat ignition deploy ./deployment/ignition/modules/Goodies42Core.ts --network localhost

deploy-core-sepolia:
	npx hardhat ignition deploy ./deployment/ignition/modules/Goodies42Core.ts --network sepolia

deploy-bonus-local:
	npx hardhat ignition deploy ./deployment/ignition/modules/Goodies42Bonus.ts --network localhost

deploy-bonus-sepolia:
	npx hardhat ignition deploy ./deployment/ignition/modules/Goodies42Bonus.ts --network sepolia

demo:
	npx hardhat run code/scripts/demo.js

clean:
	npx hardhat clean
