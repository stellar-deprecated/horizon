package codegen

import (
	"errors"
	"fmt"
	"go/ast"
	"io/ioutil"
	"os"
	"reflect"
	"strings"
)

func ExtractArgs(ctx *Context, stp *ast.StructType, name string) ([]string, error) {
	var found *ast.Field

	for _, f := range stp.Fields.List {
		fname, err := nameFromFieldType(ctx, f.Type)
		if err != nil {
			return nil, err
		}

		if name == fname {
			found = f
		}
	}

	if found == nil {
		return nil, errors.New("Couldn't find template invocation: " + name)
	}

	if found.Tag == nil {
		return nil, nil
	}

	tag := reflect.StructTag(found.Tag.Value[1 : len(found.Tag.Value)-1])

	return strings.Split(tag.Get("template"), ","), nil
}

func ExtractTemplatesFromType(ctx *Context, stp *ast.StructType) (result []string, err error) {
	for _, f := range stp.Fields.List {
		var name string
		name, err = nameFromFieldType(ctx, f.Type)
		if err != nil {
			return
		}

		if _, ok := ctx.Templates[name]; ok {
			result = append(result, name)

			if len(f.Names) != 0 {
				fmt.Fprintf(os.Stderr, "warn: invocation of template '%s' has a field name\n", name)
			}
		}
	}
	return
}

func ExtractText(ctx *Context, t ast.Expr) (string, error) {
	pos := ctx.Fset.Position(t.Pos())
	end := ctx.Fset.Position(t.End())

	read, err := ioutil.ReadFile(pos.Filename)
	if err != nil {
		return "", err
	}

	return string(read[pos.Offset:end.Offset]), nil
}

func nameFromFieldType(ctx *Context, t ast.Expr) (string, error) {
	txt, err := ExtractText(ctx, t)
	if err != nil {
		return "", err
	}

	return txt, nil
}
