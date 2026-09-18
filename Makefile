vc=valk

test:
	$(vc) build ./tests --test --run

lint:
	$(vc) build ./src --lint

docs:
	$(vc) doc ./src -o docs/api.md --markdown --no-private

.PHONY: test lint docs
