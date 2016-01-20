package codegen

import (
	"errors"
	"fmt"
	"go/ast"
	"io"
	"os"
)

type TemplateContext struct {
	Name         string
	TemplateName string
	PackageName  string
	Ctx          *Context
	Struct       *ast.StructType
}

func (mc *TemplateContext) Args() []string {
	// find the field with our template's name
	result, err := ExtractArgs(mc.Ctx, mc.Struct, mc.TemplateName)

	if err != nil {
		fmt.Fprintf(os.Stderr, "warn: couldn't get args for %s on %s\n", mc.TemplateName, mc.Name)
	}

	return result
}

func (mc *TemplateContext) AddImport(name string) string {
	mc.Ctx.Imports[name] = true
	return ""
}

func RunTemplate(ctx *Context, w io.Writer, templateName string, typeName string, st *ast.StructType) error {
	template, ok := ctx.Templates[templateName]
	if !ok {
		return errors.New("Could not find template: " + templateName)
	}

	// populate the template object
	mc := &TemplateContext{
		Name:         typeName,
		TemplateName: templateName,
		PackageName:  ctx.PackageName,
		Ctx:          ctx,
		Struct:       st,
	}

	err := template.Execute(w, mc)

	return err
}
