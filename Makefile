.PHONY: docker/env
docker/env:
	@env | grep 'UPTYCS_' >> .env || true
	@env | grep 'CI_' >> .env || true
	@env | grep 'GIT' >> .env || true
	@env | grep 'OSQUERY_' >> .env || true

.PHONY: test-images
test-images: images/test/should_pass images/test/should_fail

.PHONY: images/test/should_pass
images/test/should_pass:
	@docker build --quiet --no-cache --file tests/should_pass/Dockerfile --tag should-pass:local --iidfile=should-pass-id.out .

.PHONY: images/test/should_fail
images/test/should_fail:
	@docker build --quiet --no-cache --file tests/should_fail_scan/Dockerfile --tag should-fail:local --iidfile=should-fail-id.out .
