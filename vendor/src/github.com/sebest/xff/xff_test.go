package xff

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestParse_none(t *testing.T) {
	res := Parse("")
	assert.Equal(t, "", res)
}

func TestParse_localhost(t *testing.T) {
	res := Parse("127.0.0.1")
	assert.Equal(t, "", res)
}

func TestParse_invalid(t *testing.T) {
	res := Parse("invalid")
	assert.Equal(t, "", res)
}

func TestParse_invalid_sioux(t *testing.T) {
	res := Parse("123#1#2#3")
	assert.Equal(t, "", res)
}

func TestParse_invalid_private_lookalike(t *testing.T) {
	res := Parse("102.3.2.1")
	assert.Equal(t, "102.3.2.1", res)
}

func TestParse_valid(t *testing.T) {
	res := Parse("68.45.152.220")
	assert.Equal(t, "68.45.152.220", res)
}

func TestParse_multi_first(t *testing.T) {
	res := Parse("12.13.14.15, 68.45.152.220")
	assert.Equal(t, "12.13.14.15", res)
}

func TestParse_multi_last(t *testing.T) {
	res := Parse("192.168.110.162, 190.57.149.90")
	assert.Equal(t, "190.57.149.90", res)
}

func TestParse_multi_with_invalid(t *testing.T) {
	res := Parse("192.168.110.162, invalid, 190.57.149.90")
	assert.Equal(t, "190.57.149.90", res)
}

func TestParse_multi_with_invalid2(t *testing.T) {
	res := Parse("192.168.110.162, 190.57.149.90, invalid")
	assert.Equal(t, "190.57.149.90", res)
}

func TestParse_multi_with_invalid_sioux(t *testing.T) {
	res := Parse("192.168.110.162, 190.57.149.90, 123#1#2#3")
	assert.Equal(t, "190.57.149.90", res)
}

func TestParse_ipv6_with_port(t *testing.T) {
	res := Parse("2604:2000:71a9:bf00:f178:a500:9a2d:670d")
	assert.Equal(t, "2604:2000:71a9:bf00:f178:a500:9a2d:670d", res)
}
