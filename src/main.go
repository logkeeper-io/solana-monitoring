package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/blocto/solana-go-sdk/client"
	"github.com/blocto/solana-go-sdk/rpc"
	"io"
	"log"
	"net/http"
)

const validatorPublicKey = "98TFLBJMBuZbz9U5jeK57UwURx3MWXGEfCuVVKLV7FEi"
const validatorVoteKey = "8AWEckNoepThFnsSvnyaGMi84w5ssR8iuSt94t2FtHdx"

type AccountDetails struct {
	VotePublicKey    string
	RootSlot         uint64
	EpochCredits     []client.EpochCredits
	LastVote         uint64
	EpochVoteAccount bool
	ActivatedStake   uint64
}

func (a *AccountDetails) GetEpochCredits(epoch uint64) uint64 {
	for _, j := range a.EpochCredits {
		if j.Epoch == epoch {
			return j.Credits
		}
	}

	return 0
}

type EpochDetails struct {
	epochNumber           uint64
	epochFinishedPercents float64
}

type BlocksProduction struct {
	blocksProduced      uint64
	skippedSlots        uint64
	leaderSlots         uint64
	identityPubkey      string
	totalBlocksProduced uint64
	totalSlotsSkipped   uint64
}

type PriceResponse struct {
	Solana struct {
		USD float64 `json:"usd"`
	} `json:"solana"`
}

func main() {
	c := client.NewClient(rpc.TestnetRPCEndpoint)

	// get balance
	validatorBalance, err := getBalance(c, validatorPublicKey)
	if err != nil {
		log.Fatalf("failed to get balance, err: %v", err)
	}

	voteBalance, err := getBalance(c, validatorVoteKey)
	if err != nil {
		log.Fatalf("failed to get balance, err: %v", err)
	}

	solanaPrice, err := getSolanaPrice()
	if err != nil {
		log.Fatalf("failed to get solana price, err %v", err)
	}

	fmt.Printf("Validator balance: %v\nVote balance: %v\nSolana price usd: %f\n", validatorBalance, voteBalance, solanaPrice)

	validatorBlocks, err := getBlockProduction(c, validatorPublicKey)
	if err != nil {
		log.Fatalf("failed to get validators, err %v", err)
	}

	fmt.Printf("Blocks produces: %d\nBlocks skipped: %d\nLeader slots: %d\nTotal Blocks produces: %d\nTotal Blocks skipped: %d\n",
		validatorBlocks.blocksProduced, validatorBlocks.skippedSlots, validatorBlocks.leaderSlots, validatorBlocks.totalBlocksProduced, validatorBlocks.totalSlotsSkipped)

	totalNodes, err := getClusterNodes(c)
	if err != nil {
		log.Fatalf("failed to get cluster nodes, err %v", err)
	}

	fmt.Printf("ClusterNodes: %v\n", totalNodes)

	epochInfo, err := getEpochDetails(c)
	if err != nil {
		log.Fatalf("failed to get epoch information, err %v", err)
	}

	fmt.Printf("Epoch: %v EpochElapsed: %.2f\n", epochInfo.epochNumber, epochInfo.epochFinishedPercents)

	voteAck, err := getVoteAccounts(c, validatorVoteKey)
	if err != nil {
		log.Fatalf("failed to get validators, err %v", err)
	}

	fmt.Printf("Epoch Credits: %v \n", voteAck.GetEpochCredits(epochInfo.epochNumber))
	fmt.Printf("ACk details: %v\n", voteAck.EpochCredits)

	//// for advanced usage. fetch full rpc response
	//res, err := c.RpcClient.GetBalance(
	//	context.TODO(),
	//	"7Y1mo8YnxNJtotPKHK18naWYeMYHBWrKXt1hV2HwwtRT",
	//)
	//if err != nil {
	//	log.Fatalf("failed to get balance via rpc client, err: %v", err)
	//}
	//fmt.Printf("response: %+v\n", res)
}

func getEpochDetails(client *client.Client) (*EpochDetails, error) {
	epochInfo, err := client.GetEpochInfo(context.TODO())
	if err != nil {
		return nil, err
	}
	num := epochInfo.Epoch
	slotIndex := epochInfo.SlotIndex
	slotsInEpoch := epochInfo.SlotsInEpoch
	var percentsFinished float64
	percentsFinished = 100 * (float64(slotIndex) / float64(slotsInEpoch))

	return &EpochDetails{
		epochNumber:           num,
		epochFinishedPercents: percentsFinished,
	}, nil
}

func getClusterNodes(client *client.Client) (uint64, error) {
	nodes, err := client.GetClusterNodes(context.TODO())
	if err != nil {
		return 0, err
	}

	return uint64(len(nodes)), nil
}
func getBlockProduction(client *client.Client, validatorPub string) (*BlocksProduction, error) {
	var result BlocksProduction
	resp, err := client.RpcClient.GetBlockProduction(context.TODO())
	if err != nil {
		return nil, err
	}
	var totalLeaderSlots uint64 = 0
	var totalBlocks uint64 = 0

	result.blocksProduced = resp.Result.Value.ByIdentity[validatorPub][1]
	result.leaderSlots = resp.Result.Value.ByIdentity[validatorPub][0]
	result.skippedSlots = resp.Result.Value.ByIdentity[validatorPub][0] - resp.Result.Value.ByIdentity[validatorPub][1]
	result.identityPubkey = validatorPub
	result.totalBlocksProduced = resp.Result.Value.Range.LastSlot - resp.Result.Value.Range.FirstSlot

	for _, j := range resp.Result.Value.ByIdentity {
		totalBlocks += j[1]
		totalLeaderSlots += j[0]
	}
	result.totalSlotsSkipped = totalLeaderSlots - totalBlocks

	return &result, nil
}

func getVoteAccounts(client *client.Client, votePub string) (*AccountDetails, error) {
	var ackDetails AccountDetails
	result, err := client.GetVoteAccounts(context.TODO())
	if err != nil {
		return nil, err
	}

	for _, j := range result.Current {
		if j.VotePubkey.String() == votePub {
			ackDetails.ActivatedStake = j.ActivatedStake
			ackDetails.VotePublicKey = votePub
			ackDetails.RootSlot = j.RootSlot
			ackDetails.LastVote = j.LastVote
			ackDetails.EpochCredits = j.EpochCredits
			ackDetails.EpochVoteAccount = j.EpochVoteAccount
		}
	}

	return &ackDetails, nil
}

func getBalance(client *client.Client, pubKey string) (uint64, error) {
	balance, err := client.GetBalance(
		context.TODO(),
		pubKey,
	)
	if err != nil {
		log.Fatalf("failed to get balance, err: %v", err)
		return 0, err
	}

	return balance, nil
}

func getSolanaPrice() (float64, error) {
	resp, err := http.Get("https://api.coingecko.com/api/v3/simple/price?ids=solana&vs_currencies=usd")
	if err != nil {
		return 0, err
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return 0, err
	}

	var priceResponse PriceResponse

	err = json.Unmarshal(body, &priceResponse)
	if err != nil {
		return 0, err
	}

	return priceResponse.Solana.USD, nil
}
