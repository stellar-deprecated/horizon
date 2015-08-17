package strkey_test

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	"testing"
)

func TestStrkey(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Strkey Suite")
}
