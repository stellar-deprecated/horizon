package main

import (
	"errors"
	"fmt"
)

var ErrEmptyStack = errors.New("Empty stack!")

type stack struct {
	top int
}

type StringStack struct {
	stack `template:"string"`
	data  []string
}

type Message struct {
	Sender string
	Body   string
}

type MessageStack struct {
	stack `template:"Message"`
	data  []Message
}

func main() {
	sstack := &StringStack{}
	sstack.Push("hello")
	sstack.Push("goodbye")

	fmt.Println(sstack.Peek())
	sstack.Pop()
	fmt.Println(sstack.Peek())

	mstack := &MessageStack{}
	mstack.Push(Message{Sender: "me", Body: "Hello"})
	mstack.Push(Message{Sender: "you", Body: "Goodbye"})

	fmt.Println(mstack.Peek())
	mstack.Pop()
	fmt.Println(mstack.Peek())
}
