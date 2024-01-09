package main

import (
	"encoding/json"
	"fmt"

	"strconv"
	"strings"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type SmartContract struct {
	contractapi.Contract
}

type Bond struct {
	Amount int    `json:"amount"`
	CUSIP  string `json:"cusip"`
	Owner  string `json:"owner"`
}

type Auction struct {
	Bond          Bond    `json:"bond"`
	HighestBid    float64 `json:"highestBid"`
	HighestBidder string  `json:"highestBidder"`
}

func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	bonds := []Bond{
		{Amount: 10009, CUSIP: "037833100", Owner: "Org1MSP"},
		{Amount: 20000, CUSIP: "085937144", Owner: "Org2MSP"},
		{Amount: 30000, CUSIP: "587987145", Owner: "Org2MSP"},
	}

	for _, bond := range bonds {
		bondJSON, err := json.Marshal(bond)
		if err != nil {
			return err
		}

		err = ctx.GetStub().PutState(bond.CUSIP, bondJSON)
		if err != nil {
			return fmt.Errorf("failed to put to world state. %v", err)
		}
	}

	return nil
}

func (s *SmartContract) StartAuction(ctx contractapi.TransactionContextInterface, cusip string) (*Auction, error) {
	bondJSON, err := ctx.GetStub().GetState(cusip)
	if err != nil {
		return nil, fmt.Errorf("failed to read bond from world state: %v", err)
	}
	if bondJSON == nil {
		return nil, fmt.Errorf("bond with CUSIP %s does not exist", cusip)
	}

	var bond Bond
	err = json.Unmarshal(bondJSON, &bond)
	if err != nil {
		return nil, err
	}

	auction := Auction{
		Bond:          bond,
		HighestBid:    0.0,
		HighestBidder: "",
	}
	auctionJSON, err := json.Marshal(auction)
	if err != nil {
		return nil, err
	}

	err = ctx.GetStub().PutState("AUCTION_"+auction.Bond.CUSIP, auctionJSON)
	if err != nil {
		return nil, fmt.Errorf("failed to put auction to world state: %v", err)
	}

	return &auction, nil
}

func (s *SmartContract) QueryAuction(ctx contractapi.TransactionContextInterface, cusip string) (*Auction, error) {
	auctionJSON, err := ctx.GetStub().GetState("AUCTION_" + cusip)
	if err != nil {
		return nil, fmt.Errorf("failed to read auction from world state: %v", err)
	}
	if auctionJSON == nil {
		return nil, fmt.Errorf("auction for bond with CUSIP %s does not exist", cusip)
	}

	var auction Auction
	err = json.Unmarshal(auctionJSON, &auction)
	if err != nil {
		return nil, err
	}

	return &auction, nil
}

func (s *SmartContract) QueryBond(ctx contractapi.TransactionContextInterface, cusip string) (*Bond, error) {
	bondJSON, err := ctx.GetStub().GetState(cusip)
	if err != nil {
		return nil, fmt.Errorf("failed to read bond from world state: %v", err)
	}
	if bondJSON == nil {
		return nil, fmt.Errorf("bond with CUSIP %s does not exist", cusip)
	}

	var bond Bond
	err = json.Unmarshal(bondJSON, &bond)
	if err != nil {
		return nil, err
	}

	return &bond, nil
}

func (s *SmartContract) QueryAllBonds(ctx contractapi.TransactionContextInterface) ([]interface{}, error) {
	resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
		return nil, fmt.Errorf("failed to get state by range: %v", err)
	}
	defer resultsIterator.Close()

	var items []interface{}
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, fmt.Errorf("failed to iterate over results: %v", err)
		}

		// Determine the type of item based on the key prefix
		// var item interface{}
		if strings.HasPrefix(queryResponse.Key, "AUCTION_") {
			// It's an Auction item
			// var auction Auction
			// err := json.Unmarshal(queryResponse.Value, &auction)
			// if err != nil {
			// 	return nil, fmt.Errorf("failed to unmarshal Auction: %v", err)
			// }
			// item = auction
		} else {
			var item interface{}
			// It's a Bond item
			var bond Bond
			err := json.Unmarshal(queryResponse.Value, &bond)
			if err != nil {
				return nil, fmt.Errorf("failed to unmarshal Bond: %v", err)
			}
			item = bond
			items = append(items, item)
		}

	}

	return items, nil
}

func (s *SmartContract) Bid(ctx contractapi.TransactionContextInterface, cusip string, bidAmountStr string) (*Auction, error) {
	auctionID := "AUCTION_" + cusip
	bidAmount, err := strconv.ParseFloat(bidAmountStr, 64)
	if err != nil {
		return nil, fmt.Errorf("failed to parse bid amount: %v", err)
	}

	auctionJSON, err := ctx.GetStub().GetState(auctionID)
	if err != nil {
		return nil, fmt.Errorf("failed to read auction from world state: %v", err)
	}
	if auctionJSON == nil {
		return nil, fmt.Errorf("auction for bond with CUSIP %s does not exist", cusip)
	}

	var auction Auction
	err = json.Unmarshal(auctionJSON, &auction)
	if err != nil {
		return nil, err
	}

	mspID, err := ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return nil, err
	}

	if bidAmount > auction.HighestBid {
		auction.HighestBid = bidAmount
		auction.HighestBidder = mspID

		auctionJSON, err = json.Marshal(auction)
		if err != nil {
			return nil, err
		}

		return nil, ctx.GetStub().PutState(auctionID, auctionJSON)
	}

	return nil, fmt.Errorf("your bid isn't high enough", err)
}

func (s *SmartContract) EndAuction(ctx contractapi.TransactionContextInterface, cusip string) (*Auction, error) {
	auctionJSON, err := ctx.GetStub().GetState("AUCTION_" + cusip)
	if err != nil {
		return nil, fmt.Errorf("failed to read auction from world state: %v", err)
	}
	if auctionJSON == nil {
		return nil, fmt.Errorf("auction for bond with CUSIP %s does not exist", cusip)
	}

	var auction Auction
	err = json.Unmarshal(auctionJSON, &auction)
	if err != nil {
		return nil, err
	}

	auction.Bond.Owner = auction.HighestBidder

	bondJSON, err := json.Marshal(auction.Bond)
	if err != nil {
		return nil, err
	}
	err = ctx.GetStub().PutState(auction.Bond.CUSIP, bondJSON)
	if err != nil {
		return nil, fmt.Errorf("failed to put bond to world state: %v", err)
	}

	err = ctx.GetStub().DelState("AUCTION_" + auction.Bond.CUSIP)
	if err != nil {
		return nil, fmt.Errorf("failed to delete auction from world state: %v", err)
	}

	return &auction, nil
}

func main() {
	chaincode, err := contractapi.NewChaincode(&SmartContract{})
	if err != nil {
		fmt.Printf("Error creating mybondcc chaincode: %v\n", err)
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting mybondcc chaincode: %v\n", err)
	}
}
