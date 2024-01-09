#!/bin/bash

#
# 1. Preparation Steps
#

# Gives permission to access certificate folders for Org1 & Org2
sudo chmod -R 777 ..

./network.sh down

# Test-Network configuration variables 
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/

# Org1
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

#
# 2. Build the chaincode
#

cd ../bond-auction/chaincode

go build

cd ../../test-network

#
# 3. Initialize Test-Network with Auction Chaincode
#

./network.sh up createChannel

./network.sh deployCC -ccn bond-auction-cc -ccp ../bond-auction/chaincode -ccl go

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n bond-auction-cc --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

#
# 4. Serve Rest API
#

cd ../bond-auction/rest-api

go mod download

go run main-org1.go
