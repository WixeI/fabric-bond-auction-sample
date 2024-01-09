package web

import (
	"fmt"
	"net/http"

	"github.com/hyperledger/fabric-gateway/pkg/client"
)

// OrgSetup contains organization's config to interact with the network.
type OrgSetup struct {
	OrgName      string
	MSPID        string
	CryptoPath   string
	CertPath     string
	KeyPath      string
	TLSCertPath  string
	PeerEndpoint string
	GatewayPeer  string
	Gateway      client.Gateway
}

// Serve starts http web server.
func Serve(setups OrgSetup) {
	http.HandleFunc("/query", setups.Query)
	http.HandleFunc("/invoke", setups.Invoke)

	var err error

	for port := 3000; port <= 3100; port++ {
		addr := fmt.Sprintf(":%d", port)
		fmt.Printf("Trying to listen on %s... ", addr)

		if err = http.ListenAndServe(addr, nil); err == nil {
			// If successfully listened, break the loop
			fmt.Println("Listening on http://localhost:%d/", port)
			break
		} else {
			fmt.Println(err)
		}
	}
}
