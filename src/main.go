package main

import (
	"context"
	"fmt"
	"math/big"

	"github.com/davecgh/go-spew/spew"
	"github.com/gagliardetto/solana-go"
	"github.com/gagliardetto/solana-go/rpc"
)

const myPubKey = "7Y1mo8YnxNJtotPKHK18naWYeMYHBWrKXt1hV2HwwtRT"

func main() {
	endpoint := rpc.TestNet_RPC
	client := rpc.New(endpoint)

	pubKey := solana.MustPublicKeyFromBase58(myPubKey)
	out, err := client.GetBalance(
		context.TODO(),
		pubKey,
		rpc.CommitmentFinalized,
	)
	if err != nil {
		panic(err)
	}
	spew.Dump(out)
	spew.Dump(out.Value) // total lamports on the account; 1 sol = 1000000000 lamports

	var lamportsOnAccount = new(big.Float).SetUint64(uint64(out.Value))
	// Convert lamports to sol:
	var solBalance = new(big.Float).Quo(lamportsOnAccount, new(big.Float).SetUint64(solana.LAMPORTS_PER_SOL))

	// WARNING: this is not a precise conversion.
	fmt.Println("◎", solBalance.Text('f', 10))

	//getClusterNodes()
	getVoteAccounts()
}

func getClusterNodes() {
	endpoint := rpc.TestNet_RPC
	client := rpc.New(endpoint)

	out, err := client.GetClusterNodes(
		context.TODO(),
	)
	if err != nil {
		panic(err)
	}

	for _, j := range out {
		if j.Pubkey.String() == myPubKey {
			fmt.Println("OK")
			fmt.Printf("Gossip [%s]\n", *j.Gossip)
			fmt.Printf("RPC [%s]\n", *j.RPC)
			fmt.Printf("TPU [%s]\n", *j.TPU)
			fmt.Printf("Versuib[%s]\n", *j.Version)
			fmt.Printf("FeatureSet[%d]\n", j.FeatureSet)
			fmt.Printf("TPUQUIC[%s]\n", *j.TPUQUIC)
			fmt.Printf("[%d]\n", j.ShredVersion)
		}
		//fmt.Println(j.Pubkey)
	}
	//spew.Dump(out)
}

func getVoteAccounts() {
	endpoint := rpc.TestNet_RPC
	client := rpc.New(endpoint)

	pubKey := solana.MustPublicKeyFromBase58("vot33MHDqT6nSwubGzqtc6m16ChcUywxV7tNULF19Vu")
	out, err := client.GetVoteAccounts(
		context.TODO(),
		&rpc.GetVoteAccountsOpts{
			VotePubkey: &pubKey,
		},
	)
	if err != nil {
		panic(err)
	}
	//spew.Dump(out)
	fmt.Println(out.Delinquent)
	for _, j := range out.Current {
		fmt.Println(j.VotePubkey.String())
		if j.VotePubkey.String() == myPubKey {
			fmt.Printf("Pub key [%s]\n", j.VotePubkey.String())
			fmt.Printf("Epoch Credits[%v]\n", j.EpochCredits)
		}
	}

}
