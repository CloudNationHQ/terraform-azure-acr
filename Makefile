.PHONY: test

export EXAMPLE

test:
	cd tests && go test -v -timeout 60m -run TestApplyNoError/$(EXAMPLE) ./acr_test.go
