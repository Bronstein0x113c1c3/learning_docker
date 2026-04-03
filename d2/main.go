package main

import (
	"log"
	"net"
	"os"
	"os/signal"
)

func listen_chan(lis net.Listener) chan net.Conn {
	conn_chan := make(chan net.Conn, 10)
	go func() {
		defer close(conn_chan)
		for {
			conn, err := lis.Accept()
			if err != nil {
				return
			}
			conn_chan <- conn
		}

	}()
	return conn_chan
}

func handle_conn(conn net.Conn, sig chan os.Signal) error {
	defer conn.Close()
	for {
		data := make([]byte, 1024)
		n, err := conn.Read(data)
		if err != nil {
			return err
		}
		select{
			case <-sig:
				return nil
			default:
				conn.Write(data[:n])
		}

	}
}

func main() {
	lis, err := net.Listen("tcp", ":8080")
	if err != nil {
		log.Fatalln(err)
	}
	defer lis.Close()

	sig := make(chan os.Signal, 1)
	defer close(sig)
	signal.Notify(sig, os.Interrupt)

	conn_chan := listen_chan(lis)

	for {
		select {
		case <-sig:
			return

		case conn := <-conn_chan:
			go handle_conn(conn, sig)
		}
	}

	// go func(){
	// 	for{
	//
	// 	}
	// }
}
