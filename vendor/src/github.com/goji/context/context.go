// Package context provides Goji integration with go.net/context.
package context

import (
	"github.com/zenazn/goji/web"
	"golang.org/x/net/context"
)

type ctx struct {
	c *web.C
	context.Context
}

func (c ctx) Value(key interface{}) interface{} {
	if key == &ckey {
		return c.c
	}
	if c.c.Env != nil {
		if v, ok := c.c.Env[key]; ok {
			return v
		}
	}
	return c.Context.Value(key)
}
