package test

// Finish finishes the test, logging any accumulated horizon logs to the logs
// output
func (t *T) Finish() {
	if t.LogBuffer.Len() > 0 {
		t.T.Log("\n" + t.LogBuffer.String())
	}
}

// Scenario loads the named sql scenario into the database
func (t *T) Scenario(name string) *T {
	LoadScenario(name)
	return t
}

// Scenario loads the named sql scenario into the database
func (t *T) ScenarioWithoutHorizon(name string) *T {
	LoadScenarioWithoutHorizon(name)
	return t
}
