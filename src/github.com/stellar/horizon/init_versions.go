package horizon

import (
	"encoding/json"
	"fmt"
	"github.com/stellar/horizon/log"
	"io/ioutil"
	"net/http"
)

func initStellarCoreVersion(app *App) {
	if app.config.StellarCoreUrl == "" {
		return
	}

	resp, err := http.Get(fmt.Sprint(app.config.StellarCoreUrl, "/info"))

	if err != nil {
		log.Warnf(app.ctx, "could not load stellar-core version: %s", err)
		return
	}

	defer resp.Body.Close()
	contents, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Warnf(app.ctx, "could not load stellar-core version: %s", err)
		return
	}

	var responseJson map[string]*json.RawMessage
	err = json.Unmarshal(contents, &responseJson)

	var serverInfo map[string]string
	err = json.Unmarshal(*responseJson["info"], &serverInfo)
	app.coreVersion = serverInfo["build"]
}

func init() {
	appInit.Add("stellarCoreVersion", initStellarCoreVersion, "app-context", "log")
}
