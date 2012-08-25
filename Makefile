MOCHA = @./node_modules/.bin/mocha \
	--compilers coffee:coffee-script

FILES?=`find ./test -type f -name '*.coffee'`
export NODE_PATH=./app

xunit:
	$(MOCHA) -R xunit $(FILES)

test:
	$(MOCHA) -R spec $(FILES)

#test:
#	$(MOCHA) --ignore-leaks -R spec $(FILES)

debug:
	$(MOCHA) --debug-brk -R spec $(FILES)

watch:
	$(MOCHA) -R dot -w $(FILES)

update:
	@npm install

.PHONY: test
