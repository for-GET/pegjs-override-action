.PHONY: all clean prepublish test ci

all: index.js

index.js: index.coffee
	@$(eval input := $<)
	@coffee -c $(input)

clean:
	@rm -f index.js

prepublish: clean all

test:
	@testem ci

testem:
	@testem
