package main

// MustExecute behaves like Execute, but panics if an error occurs.
func (cmd *HelloCommand) MustExecute() interface{} {
	result, err := cmd.Execute()

	if err != nil {
		panic(err)
	}

	return result
}

// MustExecute behaves like Execute, but panics if an error occurs.
func (cmd *GoodbyeCommand) MustExecute() interface{} {
	result, err := cmd.Execute()

	if err != nil {
		panic(err)
	}

	return result
}
