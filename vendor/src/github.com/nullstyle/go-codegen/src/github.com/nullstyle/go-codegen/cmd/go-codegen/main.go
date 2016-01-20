package main

import (
	"log"
	"os"

	macro "github.com/nullstyle/go-codegen"
)

func main() {
	args := os.Args[1:]
	if len(args) == 0 {
		args = []string{"."}
	}

	for _, arg := range args {
		err := macro.Process(arg)

		if err != nil {
			log.Fatalln(err)
		}
	}
}
