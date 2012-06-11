test:
	@NODE_ENV=test ./node_modules/mocha/bin/mocha \
		test/*_spec.coffee

.PHONY: test
