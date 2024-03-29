SHELL := /bin/sh
PSXMCVERSION := $(shell perl -I PlayStation-MemoryCard/lib -MPlayStation::MemoryCard -e 'print substr($$PlayStation::MemoryCard::VERSION, 1)' 2>/dev/null)
APPERLM := $(shell command -v apperlm || echo perl -I../Perl-Dist-APPerl/lib ../Perl-Dist-APPerl/script/apperlm)

.PHONY: all
all: PlayStation-MemoryCard standalone ape

.PHONY: clean
clean: PlayStation-MemoryCard/Makefile
	$(MAKE) -C PlayStation-MemoryCard veryclean
	rm -rf psx-mc-cli*standalone*
	rm -rf psx-mc-cli*ape*

PlayStation-MemoryCard/Makefile: PlayStation-MemoryCard/Makefile.PL
	cd PlayStation-MemoryCard && perl Makefile.PL

.PHONY: PlayStation-MemoryCard
PlayStation-MemoryCard: PlayStation-MemoryCard/Makefile
	$(MAKE) -C PlayStation-MemoryCard

.PHONY: psx-mc-cli-v$(PSXMCVERSION)-standalone
psx-mc-cli-v$(PSXMCVERSION)-standalone:
	[ ! -f $@.tar.gz ]
	[ ! -f $@.zip ]
	[ ! -d $@ ]
	mkdir -p $@
	cp -r PlayStation-MemoryCard/lib $@/
	cp -r PlayStation-MemoryCard/script $@/
	cp PlayStation-MemoryCard/Changes $@/
	cp LICENSE $@/
	cp README.md $@/
	cp -r gifenc-pl/lib/* $@/lib
	perl build_intree_bin.pl $@

psx-mc-cli-v$(PSXMCVERSION)-standalone.tar.gz: psx-mc-cli-v$(PSXMCVERSION)-standalone
	tar -czf $@ psx-mc-cli-v$(PSXMCVERSION)-standalone --owner=0 --group=0

psx-mc-cli-v$(PSXMCVERSION)-standalone.zip: psx-mc-cli-v$(PSXMCVERSION)-standalone
	zip -r $@ psx-mc-cli-v$(PSXMCVERSION)-standalone

psx-mc-cli-v$(PSXMCVERSION)-ape.com: apperl-project.json
	$(APPERLM) checkout psx_mc_cli_with_perldoc
	$(APPERLM) configure
	$(APPERLM) build
	mv psx_mc_cli.com $@

.PHONY: standalone-tarball
standalone-tarball: psx-mc-cli-v$(PSXMCVERSION)-standalone.tar.gz

.PHONY: standalone-zip
standalone-zip: psx-mc-cli-v$(PSXMCVERSION)-standalone.zip

.PHONY: standalone-all
standalone-all: standalone-tarball standalone-zip

.PHONY: ape
ape: psx-mc-cli-v$(PSXMCVERSION)-ape.com
