package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

type Response struct {
	Message   string    `json:"message"`
	Timestamp time.Time `json:"timestamp"`
	Hostname  string    `json:"hostname"`
	Version   string    `json:"version"`
}

func handler(w http.ResponseWriter, r *http.Request) {
	hostname, _ := os.Hostname()
	resp := Response{
		Message:   "Hello from the Go Application!",
		Timestamp: time.Now(),
		Hostname:  hostname,
		Version:   "v1.1.2",
	}

	log.Printf("Received request from %s", r.RemoteAddr)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func main() {
	http.HandleFunc("/", handler)
	port := "8080"
	fmt.Printf("Starting server on port %s...\n", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}
