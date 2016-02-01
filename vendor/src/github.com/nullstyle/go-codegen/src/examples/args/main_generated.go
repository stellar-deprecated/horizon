package main

func (stack *StringStack) Push(val string) {
	stack.data = append(stack.data, val)
	stack.top++
}

func (stack *StringStack) Pop() error {
	if stack.top == 0 {
		return ErrEmptyStack
	}

	stack.top--
	return nil
}

func (stack *StringStack) Peek() (result string, err error) {
	if stack.top <= 0 {
		err = ErrEmptyStack
		return
	}

	result = stack.data[stack.top-1]
	return
}
func (stack *MessageStack) Push(val Message) {
	stack.data = append(stack.data, val)
	stack.top++
}

func (stack *MessageStack) Pop() error {
	if stack.top == 0 {
		return ErrEmptyStack
	}

	stack.top--
	return nil
}

func (stack *MessageStack) Peek() (result Message, err error) {
	if stack.top <= 0 {
		err = ErrEmptyStack
		return
	}

	result = stack.data[stack.top-1]
	return
}
