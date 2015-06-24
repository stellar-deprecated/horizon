package xff

import (
	"net"
	"net/http"
	"strings"
)

var privateMasks = func() []net.IPNet {
	masks := []net.IPNet{}
	for _, cidr := range []string{"10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "fc00::/7"} {
		_, net, err := net.ParseCIDR(cidr)
		if err != nil {
			panic(err)
		}
		masks = append(masks, *net)
	}
	return masks
}()

// IsPublicIP returns true if the given IP can be routed on the Internet
func IsPublicIP(ip net.IP) bool {
	if !ip.IsGlobalUnicast() {
		return false
	}
	for _, mask := range privateMasks {
		if mask.Contains(ip) {
			return false
		}
	}
	return true
}

// Parse parses the value of the X-Forwarded-For Header and returns the IP address.
func Parse(ipList string) string {
	for _, ip := range strings.Split(ipList, ",") {
		ip = strings.TrimSpace(ip)
		if IP := net.ParseIP(ip); IP != nil && IsPublicIP(IP) {
			return ip
		}
	}
	return ""
}

// GetRemoteAddr parses the given request, resolves the X-Forwarded-For header
// and returns the resolved remote address.
func GetRemoteAddr(r *http.Request) string {
	xff := r.Header.Get("X-Forwarded-For")
	var ip string
	if xff != "" {
		ip = Parse(xff)
	}
	_, oport, err := net.SplitHostPort(r.RemoteAddr)
	if err == nil && ip != "" {
		return net.JoinHostPort(ip, oport)
	}
	return r.RemoteAddr
}

// Handler is a middleware to update RemoteAdd from X-Fowarded-* Headers.
func Handler(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		r.RemoteAddr = GetRemoteAddr(r)
		h.ServeHTTP(w, r)
	})
}

// HandlerFunc is a Martini compatible handler
func HandlerFunc(w http.ResponseWriter, r *http.Request) {
	r.RemoteAddr = GetRemoteAddr(r)
}

// XFF is a Negroni compatible interface
func XFF(w http.ResponseWriter, r *http.Request, next http.HandlerFunc) {
	r.RemoteAddr = GetRemoteAddr(r)
	next(w, r)
}
