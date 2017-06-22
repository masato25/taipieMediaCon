// Copyright 2015 The Gorilla WebSocket Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// +build ignore

package main

import (
	"encoding/json"
	"flag"
	"net/url"
	"os"
	"os/exec"
	"os/signal"
	"sync"
	"time"

	colorable "github.com/mattn/go-colorable"
	log "github.com/sirupsen/logrus"
	"github.com/spf13/viper"

	"github.com/elgs/jsonql"
	"github.com/gorilla/websocket"
)

type JobInfo struct {
	Mutex sync.Mutex
	Name  string
	Run   bool
}

var JobInfoObj = JobInfo{}
var c *websocket.Conn
var addr = flag.String("addr", "0", "http service address")

func conn(surl string) {
	JobInfoObj.Mutex.Lock()
	for {
		var err error
		c, _, err = websocket.DefaultDialer.Dial(surl, nil)
		if err != nil {
			log.Errorf("dial: %v\n", err)
		} else {
			break
		}
		time.Sleep(3 * time.Second)
	}
	c.WriteJSON(map[string]interface{}{
		"topic": "room:lobby:" + viper.GetString("name"),
		"event": "phx_join",
		"id":    viper.GetString("name"),
		"payload": map[string]interface{}{
			"name":     viper.GetString("name"),
			"job_name": JobInfoObj.Name,
			"job_run":  JobInfoObj.Run,
		},
		"ref": 1,
	})

	_, message, err := c.ReadMessage()
	if err != nil {
		log.Errorf("parse response got error: %s", err)
	}
	parser, err := jsonql.NewStringQuery(string(message))
	if err != nil {
		log.Errorf("parse response got error: %s", err)
	}
	rstatus, _ := parser.Query("payload.status!='ok'")
	if message != nil && rstatus == nil {
		log.Infof("joined to: %s", message)
	} else {
		log.Fatalf("will stop, bacause of '%v'", rstatus)
	}

	log.Info("connection created")
	JobInfoObj.Mutex.Unlock()
	return
}

type ServerMsg struct {
	Topic   string `json:"topic"`
	Ref     int    `json:"ref"`
	Event   string `json:"event"`
	Payload ServerComm
}
type ServerComm struct {
	StartTime int64  `json:"start_time"`
	EndTime   int64  `json:"end_time"`
	Name      string `json:"name"`
	Command   string `json:"command"`
}

func reading(done chan int, u url.URL, reconn chan int) {
	sm := ServerMsg{}
	cmd := &exec.Cmd{}
	log.Info("start reading websocket message")
	defer func() {
		if r := recover(); r != nil {
			log.Errorf("reading socket message error: %v", r)
		}
		JobInfoObj.Mutex.Unlock()
		done <- 1
	}()
	for {
		log.Debug("will read message")
		if c == nil {
			log.Errorln("connection lost will reconnect")
			reconn <- 1
			time.Sleep(time.Millisecond * 500)
			//waiting connection finished
		}
		JobInfoObj.Mutex.Lock()
		_, message, err := c.ReadMessage()
		JobInfoObj.Mutex.Unlock()
		if err != nil {
			log.Errorf("read: %v\n", err)
			c = nil
			continue
		}
		log.Debugf("recv: %s", message)
		if message != nil {
			json.Unmarshal(message, &sm)
			if !viper.GetBool("debug") {
				log.Infof("recv: %s", message)
			}
			if sm.Event == "run" && !JobInfoObj.Run {
				JobInfoObj.Run = true
				JobInfoObj.Name = sm.Payload.Name
				log.Infof("sm.Event: %v\n", sm.Event)
				log.Infof("will run: %v\n", sm.Payload.Command)
				cmd = exec.Command(sm.Payload.Command)
				cmd.Start()
			} else if sm.Event == "stop" && JobInfoObj.Run {
				cmd.Process.Kill()
				log.Infof("*********************** job %s killed **********************", JobInfoObj.Name)
				JobInfoObj.Run = false
				JobInfoObj.Name = ""
			} else if sm.Event == "continue" && !JobInfoObj.Run {
				JobInfoObj.Run = true
				JobInfoObj.Name = sm.Payload.Name
				log.Infof("will run: %v\n", sm.Payload.Command)
				cmd = exec.Command(sm.Payload.Command)
				cmd.Start()
			} else {
				if JobInfoObj.Run {
					if JobInfoObj.Name != sm.Payload.Name {
						cmd.Process.Kill()
					}
				}
			}
		}
	}
}
func main() {
	viper.SetConfigName("cfg")
	viper.AddConfigPath("config")
	viper.AddConfigPath(".")
	err := viper.ReadInConfig()
	if err != nil {
		log.Fatalf("read conf got error : %s", err.Error())
	}
	if viper.GetBool("debug") {
		log.SetLevel(log.DebugLevel)
	} else {
		log.SetLevel(log.InfoLevel)
	}

	if !viper.GetBool("linux") {
		log.SetFormatter(&log.TextFormatter{ForceColors: true})
		log.SetOutput(colorable.NewColorableStdout())
	} else {
		log.SetFormatter(&log.JSONFormatter{})
	}
	flag.Parse()
	if *addr == "0" {
		*addr = viper.GetString("server")
	}
	interrupt := make(chan os.Signal, 1)
	signal.Notify(interrupt, os.Interrupt)

	u := url.URL{Scheme: "ws", Host: *addr, Path: "/socket/websocket"}
	log.Printf("connecting to %s", u.String())
	reconn := make(chan int, 1)
	done := make(chan int, 1)
	done <- 1

	for {
		select {
		case <-reconn:
			go conn(u.String())
		case <-done:
			//reading got painc restart
			go reading(done, u, reconn)
		case <-interrupt:
			log.Fatalln("^c interrupt")
			// c.Close()
			// close(done)
			return
		}
	}
}
