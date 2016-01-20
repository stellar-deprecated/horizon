package codegen

import (
	"go/token"
	"path"
	"path/filepath"
	"text/template"
)

type Context struct {
	Dir         string
	Fset        *token.FileSet
	Templates   map[string]*template.Template
	PackageName string
	Imports     map[string]bool
}

func NewContext(dir string) (*Context, error) {
	result := &Context{
		Dir:         dir,
		Fset:        token.NewFileSet(),
		PackageName: "main", // default to main
	}
	return result, result.Populate()
}

func (ctx *Context) Populate() error {
	// search directory for every template in the package
	pat := path.Join(ctx.Dir, "*.tmpl")
	paths, err := filepath.Glob(pat)

	if err != nil {
		return err
	}

	ctx.Templates = make(map[string]*template.Template)
	ctx.Imports = make(map[string]bool)

	for _, p := range paths {
		base := path.Base(p)
		name := base[:len(base)-len(".tmpl")]

		t, err := template.New(base).ParseFiles(p)
		if err != nil {
			return err
		}

		ctx.Templates[name] = t
	}

	return nil
}
