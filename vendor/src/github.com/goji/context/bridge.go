package context

import (
	"github.com/zenazn/goji/web"
	"golang.org/x/net/context"
)

type private struct{}

var ckey, contextkey private

// FromC extracts the bound go.net/context.Context from a Goji context if one
// has been set, or nil if one is not available.
func FromC(c web.C) context.Context {
	if c.Env == nil {
		return nil
	}
	v, ok := c.Env[&ckey]
	if !ok {
		return nil
	}
	if ctx, ok := v.(context.Context); ok {
		return ctx
	}
	return nil
}

// ToC extracts the bound Goji context from a go.net/context.Context if one has
// been set, or the empty Goji context if one is not available.
func ToC(ctx context.Context) web.C {
	out := ctx.Value(&contextkey)
	if out == nil {
		return web.C{}
	}
	if c, ok := out.(*web.C); ok {
		return *c
	}
	return web.C{}
}

// Set makes a two-way binding between the given Goji request context and the
// given go.net/context.Context. Returns the fresh context.Context that contains
// this binding. Using the ToC and From functions will allow you to convert
// between one and the other.
//
// Note that since context.Context's are immutable, you will have to call this
// function to "re-bind" the request's canonical context.Context if you ever
// decide to change it.
func Set(c *web.C, context context.Context) context.Context {
	if c.Env == nil {
		c.Env = make(map[interface{}]interface{})
	}

	ctx := ctx{c, context}
	c.Env[&ckey] = ctx
	return ctx
}
