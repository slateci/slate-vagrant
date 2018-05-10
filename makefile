exec=ct

config:
	$(info Checking for ct in PATH...)
	$(if $(shell PATH=$(PATH) which $(exec)),,$(error No $(exec) in PATH))
	ct -in-file config.yaml -files-dir ignition > config.ign

clean:
	rm -f config.ign config.ign.merged
