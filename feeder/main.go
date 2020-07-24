package main

import (
	"bufio"
	"encoding/json"
	"github.com/gocql/gocql"
	"log"
	"os"
	"strconv"
	"time"
)

type DataItem struct {
	ID            string `json:"_id"`
	RequestHash   string `json:"requestHash"`
	Client        string `json:"client"`
	CreatedAt     string `json:"createdAt"`
	FunctionArn   string `json:"functionArn"`
	IsColdstart   bool   `json:"isColdstart"`
	IsEmpty       bool   `json:"isEmpty"`
	IsError       bool   `json:"isError"`
	IsRetry       bool   `json:"isRetry"`
	Lambda        string `json:"lambda"`
	LogGroupName  string `json:"logGroupName"`
	LogLines      string `json:"logLines"`
	LogStreamName string `json:"logStreamName"`
	ParsedData    struct {
		Version        string `json:"version"`
		RequestID      string `json:"requestId"`
		Duration       string `json:"duration"`
		BilledDuration string `json:"billedDuration"`
		MemorySize     string `json:"memorySize"`
		MaxMemoryUsed  string `json:"maxMemoryUsed"`
	} `json:"parsedData"`
	RequestID string `json:"requestId"`
	S3Bucket  string `json:"s3bucket"`
	S3Key     string `json:"s3key"`
	Timestamp string `json:"timestamp"`
}

func main() {
	// Connect to the cluster
	cluster := gocql.NewCluster("localhost")
	cluster.Keyspace = "events"
	cluster.Consistency = gocql.Quorum
	session, _ := cluster.CreateSession()
	defer session.Close()

	// Load data into db
	file, err := os.Open("data.json")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	var dataItem DataItem
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		err := json.Unmarshal(scanner.Bytes(), &dataItem)
		if err != nil {
			log.Fatal(err)
		}

		logLines, err := strconv.Atoi(dataItem.LogLines)

		// Insert data into events table
		if err := session.Query(`
	INSERT INTO events.events (
		id,
		created_at,
		account_id,
		data,
		function_arn,
		is_cold_start,
		is_empty,
		is_error,
		is_retry,
		log_group_name,
		log_lines,
		log_stream_name,
		s3bucket,
		s3key
	) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
`,
			dataItem.ID,
			time.Now().Unix(),
			dataItem.Client,
			dataItem.ParsedData,
			dataItem.FunctionArn,
			dataItem.IsColdstart,
			dataItem.IsEmpty,
			dataItem.IsError,
			dataItem.IsRetry,
			dataItem.LogGroupName,
			logLines,
			dataItem.LogLines,
			dataItem.S3Bucket,
			dataItem.S3Key,
		).Exec(); err != nil {
			log.Fatal(err)
		}

		// Insert data into events table
		if err := session.Query(`
	INSERT INTO events.events_by_account_id (
		account_id,
		event_id,
		created_at,
		data,
		function_arn,
		is_cold_start,
		is_empty,
        is_error,
		is_retry,
		log_group_name,
		log_lines,
		log_stream_name,
		s3bucket,
		s3key)
	VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?); 
`,
			dataItem.Client,
			dataItem.ID,
			time.Now().Unix(),
			dataItem.ParsedData,
			dataItem.FunctionArn,
			dataItem.IsColdstart,
			dataItem.IsEmpty,
			dataItem.IsError,
			dataItem.IsRetry,
			dataItem.LogGroupName,
			logLines,
			dataItem.LogStreamName,
			dataItem.S3Bucket,
			dataItem.S3Key,
		).Exec(); err != nil {
			log.Fatal(err)
		}
	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}
}
