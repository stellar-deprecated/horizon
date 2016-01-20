package codegen

import (
	"bytes"
	"fmt"
	"go/ast"
	"go/parser"
	"io"
	"path"
	"strings"
)

func Process(arg string) error {
	if strings.HasSuffix(arg, ".go") {
		return ProcessFilePath(arg)
	} else {
		return ProcessDir(arg)
	}
}

func ProcessDir(dir string) error {
	ctx, err := NewContext(dir)
	if err != nil {
		return err
	}

	pkgs, err := parser.ParseDir(ctx.Fset, ctx.Dir, nil, 0)

	if err != nil {
		return err
	}

	var output bytes.Buffer

	for _, pkg := range pkgs {
		for _, file := range pkg.Files {
			src, err := ProcessFile(ctx, file)

			if err != nil {
				return err
			}

			fmt.Fprintln(&output, src)
		}
	}

	return Output(ctx, "main_generated.go", output.String())
}

func ProcessFilePath(p string) error {
	ctx, err := NewContext(path.Dir(p))
	if err != nil {
		return err
	}

	file, err := parser.ParseFile(ctx.Fset, p, nil, 0)

	if err != nil {
		return err
	}

	src, err := ProcessFile(ctx, file)

	if err != nil {
		return err
	}

	base := path.Base(p)
	name := base[:len(base)-len(".go")]
	return Output(ctx, name+"_generated.go", src)
}

func ProcessFile(ctx *Context, file *ast.File) (string, error) {
	var result bytes.Buffer
	ctx.PackageName = file.Name.Name

	for _, decl := range file.Decls {
		err := ProcessDecl(ctx, &result, decl)
		if err != nil {
			return "", err
		}
	}

	return result.String(), nil
}

func ProcessDecl(ctx *Context, w io.Writer, decl ast.Decl) error {
	gdp, ok := decl.(*ast.GenDecl)

	if !ok {
		return nil
	}

	for _, spec := range gdp.Specs {
		err := ProcessSpec(ctx, w, spec)
		if err != nil {
			return err
		}
	}

	return nil
}

func ProcessSpec(ctx *Context, w io.Writer, spec ast.Spec) error {
	tsp, ok := spec.(*ast.TypeSpec)

	if !ok {
		return nil
	}

	stp, ok := tsp.Type.(*ast.StructType)

	if !ok {
		return nil
	}

	templates, err := ExtractTemplatesFromType(ctx, stp)
	if err != nil {
		return err
	}

	for _, templateName := range templates {
		err := RunTemplate(ctx, w, templateName, tsp.Name.Name, stp)
		if err != nil {
			return err
		}
	}

	return nil
}
