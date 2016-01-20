package codegen

import (
	"bytes"
	"fmt"
	"go/parser"
	"go/printer"
	"go/token"
	"io"
	"io/ioutil"
	"path"
)

func Output(ctx *Context, p string, data string) error {
	op := path.Join(ctx.Dir, p)
	var (
		unformatted bytes.Buffer
		out         bytes.Buffer
	)

	fmt.Fprintf(&unformatted, "package %s\n", ctx.PackageName)
	outputImports(ctx, &unformatted)
	unformatted.WriteString(data)

	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, p, unformatted.Bytes(), parser.ParseComments)
	if err != nil {
		return err
	}

	printer.Fprint(&out, fset, file)

	return ioutil.WriteFile(op, out.Bytes(), 0644)
}

func outputImports(ctx *Context, w io.Writer) {
	if len(ctx.Imports) == 0 {
		return
	}

	fmt.Fprint(w, "import (\n")

	for i, _ := range ctx.Imports {
		fmt.Fprintf(w, "\t\"%s\"\n", i)
	}
	fmt.Fprint(w, ")\n")

}
