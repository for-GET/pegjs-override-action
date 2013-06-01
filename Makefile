.PHONY: all clean prepublish test testem

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
