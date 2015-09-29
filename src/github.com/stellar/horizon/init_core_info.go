package horizon

import (
	"encoding/json"
	"fmt"
	"github.com/stellar/horizon/log"
	"io/ioutil"
	"net/http"
)

func initStellarCoreInfo(app *App) {
	if app.config.StellarCoreUrl == "" {
		return
	}

	fail := func(err error) {
		log.Warnf(app.ctx, "could not load stellar-core info: %s", err)
	}

	resp, err := http.Get(fmt.Sprint(app.config.StellarCoreUrl, "/info"))

	if err != nil {
		fail(err)
		return
	}

	defer resp.Body.Close()
	contents, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fail(err)
		return
	}

	var responseJson map[string]*json.RawMessage
	err = json.Unmarshal(contents, &responseJson)
	if err != nil {
		fail(err)
		return
	}

	var serverInfo map[string]string
	err = json.Unmarshal(*responseJson["info"], &serverInfo)
	if err != nil {
		fail(err)
		return
	}

	app.coreVersion = serverInfo["build"]
	app.networkPassphrase = serverInfo["network"]

	return
}

func init() {
	appInit.Add("stellarCoreInfo", initStellarCoreInfo, "app-context", "log")
}
