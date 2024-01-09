# Asset Transfer REST API Sample

This is a simple REST server written in golang with endpoints for chaincode invoke and query.

## Usage

- Setup fabric test network and deploy the asset transfer chaincode by [following this instructions](https://hyperledger-fabric.readthedocs.io/en/release-2.4/test_network.html).

- cd into rest-api-go directory
- Download required dependencies using `go mod download`
- Run `go run main.go` to run the REST server

## Sending Requests

Invoke endpoint accepts POST requests with chaincode function and arguments. Query endpoint accepts get requests with chaincode function and arguments.

### Query All Bonds [GET]

```sh
curl --request GET \
  --url 'http://localhost:3001/query?channelid=mychannel&chaincodeid=bond-auction-cc&function=QueryAllBonds'
```

### Query Specific Bond [GET]

```sh
curl --request GET \
  --url 'http://localhost:3000/query?channelid=mychannel&chaincodeid=bond-auction-cc&function=QueryBond&args=037833100'
```

### Query Specific Auction [GET]

```sh
curl --request GET \
  --url 'http://localhost:3000/query?channelid=mychannel&chaincodeid=bond-auction-cc&function=QueryAuction&args=037833100'
```

### Start Auction [POST]

```sh
curl --request POST \
  --url http://localhost:3000/invoke \
  --header 'content-type: application/x-www-form-urlencoded' \
  --data = \
  --data channelid=mychannel \
  --data chaincodeid=bond-auction-cc \
  --data function=StartAuction \
  --data args=037833100
```

### Bid in Auction [POST]

```sh
curl --request POST \
  --url http://localhost:3002/invoke \
  --header 'content-type: application/x-www-form-urlencoded' \
  --data = \
  --data channelid=mychannel \
  --data chaincodeid=bond-auction-cc \
  --data function=Bid \
  --data args=037833100 \
  --data args=7500
```

### EndAuction Auction [POST]

```sh
curl --request POST \
  --url http://localhost:3000/invoke \
  --header 'content-type: application/x-www-form-urlencoded' \
  --data = \
  --data channelid=mychannel \
  --data chaincodeid=bond-auction-cc \
  --data function=EndAuction \
  --data args=037833100
```
