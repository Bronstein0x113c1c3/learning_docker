package main

import "net"

// thread pooled - networking

type IInvoke interface {
	Invoke()
}

type QUICRequest struct {
	// func
	// conn
}

type TCPRequest struct {
	// func
	f func(net.Conn)
	// conn
	conn net.Conn

}

func main() {

	// fmt.Println("something")
	// run both 2 connections

	// create a channel for thread pool: IInvoke
	/*

	 request:= make(chan IInvoke, 10)

	 10 worker for running request., just Invoke()

	*/

	request := make(chan IInvoke, 10)



}
