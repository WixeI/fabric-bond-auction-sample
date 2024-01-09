#!/bin/bash

# Preparation Steps

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

# Build the chaincode

cd ../my-chaincodes

go build

cd ../test-network

# Initialize Test-Network with Auction Chaincode

./network.sh up createChannel

./network.sh deployCC -ccn mybondcc -ccp ../my-chaincodes -ccl go

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n mybondcc --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

# Present options to the user
while true; do
    echo "Choose an option:"
    echo "1 - Start Auction as Org1"
    echo "2 - Place Bid as Org2"
    echo "3 - End Auction as Org1"
    echo "4 - Check Auction"
    echo "5 - Check All Bonds"
    echo "0 - Exit"

    read -p "Option: " choice

    case $choice in
        1)
            # Start Auction as Org1
            # echo "Enter the argument for StartAuction:"
            # read -p "CUSIP: " CUSIP
            export CORE_PEER_TLS_ENABLED=true
            export CORE_PEER_LOCALMSPID="Org1MSP"
            export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
            export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
            export CORE_PEER_ADDRESS=localhost:7051
            peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n mybondcc --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"StartAuction","Args":["037833100"]}'
            ;;
        2)
            # Place Bid as Org2
            # echo "Enter the arguments for Bid:"
            # read -p "CUSIP: " CUSIP
            # read -p "Amount: " amount
            export CORE_PEER_TLS_ENABLED=true
            export CORE_PEER_LOCALMSPID="Org2MSP"
            export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
            export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
            export CORE_PEER_ADDRESS=localhost:9051
            peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n mybondcc --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"Bid","Args":["037833100", "75300"]}'
            ;;
        3)
            # End Auction as Org1
            # echo "Enter the argument for EndAuction:"
            # read -p "arg1: " arg1
            export CORE_PEER_TLS_ENABLED=true
            export CORE_PEER_LOCALMSPID="Org1MSP"
            export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
            export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
            export CORE_PEER_ADDRESS=localhost:7051
            peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n mybondcc --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"EndAuction","Args":["037833100"]}'
            ;;
        4)
            # Check Auction
            # echo "Enter the argument for QueryAuction:"
            #read -p "arg1: " arg1
            peer chaincode query -C mychannel -n mybondcc -c '{"Args":["QueryAuction", "037833100"]}'
            ;;
        5)
            # Check All Bonds
            peer chaincode query -C mychannel -n mybondcc -c '{"Args":["QueryAllBonds"]}'
            ;;
        0)
            # Exit the script
            exit 0
            ;;
        *)
            echo "Invalid option. Please choose a valid option."
            ;;
    esac
done

