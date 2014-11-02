# if Makefile.local exists, include it
ifneq ("$(wildcard Makefile.local)", "")
	include Makefile.local
endif

PACKER_VERSION = $(shell packer --version | sed 's/^.* //g' | sed 's/^.//')
ifneq (0.5.0, $(word 1, $(sort 0.5.0 $(PACKER_VERSION))))
$(error Packer version less than 0.5.x, please upgrade)
endif

DEBIAN76_AMD64 ?= http://cdimage.debian.org/cdimage/release/7.6.0/amd64/iso-dvd/debian-7.6.0-amd64-DVD-1.iso
DEBIAN75_AMD64 ?= http://cdimage.debian.org/cdimage/archive/7.5.0/amd64/iso-dvd/debian-7.5.0-amd64-DVD-1.iso
DEBIAN74_AMD64 ?= http://cdimage.debian.org/cdimage/archive/7.4.0/amd64/iso-dvd/debian-7.4.0-amd64-DVD-1.iso
DEBIAN6010_AMD64 ?= http://cdimage.debian.org/cdimage/archive/6.0.10/amd64/iso-cd/debian-6.0.10-amd64-CD-1.iso
DEBIAN609_AMD64 ?= http://cdimage.debian.org/cdimage/archive/6.0.9/amd64/iso-cd/debian-6.0.9-amd64-CD-1.iso
DEBIAN76_I386 ?= http://cdimage.debian.org/cdimage/release/7.6.0/i386/iso-dvd/debian-7.6.0-i386-DVD-1.iso
DEBIAN75_I386 ?= http://cdimage.debian.org/cdimage/archive/7.5.0/i386/iso-dvd/debian-7.5.0-i386-DVD-1.iso
DEBIAN74_I386 ?= http://cdimage.debian.org/cdimage/archive/7.4.0/i386/iso-dvd/debian-7.4.0-i386-DVD-1.iso
DEBIAN6010_I386 ?= http://cdimage.debian.org/cdimage/archive/6.0.10/i386/iso-cd/debian-6.0.10-i386-CD-1.iso
DEBIAN609_I386 ?= http://cdimage.debian.org/cdimage/archive/6.0.9/i386/iso-cd/debian-6.0.9-i386-CD-1.iso

# Possible values for CM: (nocm | chef | chefdk | salt | puppet)
CM ?= nocm
# Possible values for CM_VERSION: (latest | x.y.z | x.y)
CM_VERSION ?=
ifndef CM_VERSION
	ifneq ($(CM),nocm)
		CM_VERSION = latest
	endif
endif
BOX_VERSION ?= $(shell cat VERSION)
ifeq ($(CM),nocm)
	BOX_SUFFIX := -$(CM)-$(BOX_VERSION).box
else
	BOX_SUFFIX := -$(CM)$(CM_VERSION)-$(BOX_VERSION).box
endif
# Packer does not allow empty variables, so only pass variables that are defined
ifdef CM_VERSION
	PACKER_VARS := -var 'cm=$(CM)' -var 'cm_version=$(CM_VERSION)' -var 'headless=$(HEADLESS)' -var 'update=$(UPDATE)' -var 'version=$(BOX_VERSION)'
else
	PACKER_VARS := -var 'cm=$(CM)' -var 'headless=$(HEADLESS)' -var 'update=$(UPDATE)' -var 'version=$(BOX_VERSION)'
endif
ifdef PACKER_DEBUG
	PACKER := PACKER_LOG=1 packer --debug
else
	PACKER := packer
endif
BUILDER_TYPES := vmware virtualbox parallels
TEMPLATE_FILENAMES := $(wildcard *.json)
BOX_FILENAMES := $(TEMPLATE_FILENAMES:.json=$(BOX_SUFFIX))
BOX_FILES := $(foreach builder, $(BUILDER_TYPES), $(foreach box_filename, $(BOX_FILENAMES), box/$(builder)/$(box_filename)))
TEST_BOX_FILES := $(foreach builder, $(BUILDER_TYPES), $(foreach box_filename, $(BOX_FILENAMES), test-box/$(builder)/$(box_filename)))
VMWARE_BOX_DIR := box/vmware
VIRTUALBOX_BOX_DIR := box/virtualbox
PARALLELS_BOX_DIR := box/parallels
VMWARE_OUTPUT := output-vmware-iso
VIRTUALBOX_OUTPUT := output-virtualbox-iso
PARALLELS_OUTPUT := output-parallels-iso
VMWARE_BUILDER := vmware-iso
VIRTUALBOX_BUILDER := virtualbox-iso
PARALLELS_BUILDER := parallels-iso
CURRENT_DIR = $(shell pwd)
SOURCES := $(wildcard script/*.sh) $(http/*.cfg)

.PHONY: list validate

all: $(BOX_FILES)

test: $(TEST_BOX_FILES)

###############################################################################
# Target shortcuts
define SHORTCUT

$(1): vmware/$(1) virtualbox/$(1) parallels/$(1)

test-$(1): test-vmware/$(1) test-virtualbox/$(1) test-parallels/$(1)

vmware/$(1): $(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-vmware/$(1): test-$(VMWARE_BOX_DIR)/$(1)$(BOX_SUFFIX)

virtualbox/$(1): $(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-virtualbox/$(1): test-$(VIRTUALBOX_BOX_DIR)/$(1)$(BOX_SUFFIX)

parallels/$(1): $(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX)

test-parallels/$(1): test-$(PARALLELS_BOX_DIR)/$(1)$(BOX_SUFFIX)

endef

SHORTCUT_TARGETS := debian76 debian76-i386 debian75 debian75-i386 debian74 debian74-i386 debian6010 debian6010-i386 debian609 debian609-i386
$(foreach i,$(SHORTCUT_TARGETS),$(eval $(call SHORTCUT,$(i))))

###############################################################################

# Generic rule - not used currently
#$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): %.json
#	cd $(dir $<)
#	rm -rf output-vmware-iso
#	mkdir -p $(VMWARE_BOX_DIR)
#	packer build -only=vmware-iso $(PACKER_VARS) $<

$(VMWARE_BOX_DIR)/debian76$(BOX_SUFFIX): debian76.json $(SOURCES)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN76_AMD64)" $<

$(VMWARE_BOX_DIR)/debian75$(BOX_SUFFIX): debian75.json $(SOURCES)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN75_AMD64)" $<

$(VMWARE_BOX_DIR)/debian74$(BOX_SUFFIX): debian74.json $(SOURCES)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN74_AMD64)" $<

$(VMWARE_BOX_DIR)/debian6010$(BOX_SUFFIX): debian6010.json $(SOURCES)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN6010_AMD64)" $<

$(VMWARE_BOX_DIR)/debian609$(BOX_SUFFIX): debian609.json $(SOURCES)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN609_AMD64)" $<

$(VMWARE_BOX_DIR)/debian76-i386$(BOX_SUFFIX): debian76-i386.json $(SOURCES)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN76_I386)" $<

$(VMWARE_BOX_DIR)/debian75-i386$(BOX_SUFFIX): debian75-i386.json $(SOURCES)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN75_I386)" $<

$(VMWARE_BOX_DIR)/debian74-i386$(BOX_SUFFIX): debian74-i386.json $(SOURCES)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN74_I386)" $<

$(VMWARE_BOX_DIR)/debian6010-i386$(BOX_SUFFIX): debian6010-i386.json $(SOURCES)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN6010_I386)" $<

$(VMWARE_BOX_DIR)/debian609-i386$(BOX_SUFFIX): debian609-i386.json $(SOURCES)
	rm -rf $(VMWARE_OUTPUT)
	mkdir -p $(VMWARE_BOX_DIR)
	$(PACKER) build -only=$(VMWARE_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN609_I386)" $<

# Generic rule - not used currently
#$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): %.json
#	cd $(dir $<)
#	rm -rf output-virtualbox-iso
#	mkdir -p $(VIRTUALBOX_BOX_DIR)
#	packer build -only=virtualbox-iso $(PACKER_VARS) $<

$(VIRTUALBOX_BOX_DIR)/debian76$(BOX_SUFFIX): debian76.json $(SOURCES)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN76_AMD64)" $<

$(VIRTUALBOX_BOX_DIR)/debian75$(BOX_SUFFIX): debian75.json $(SOURCES)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN75_AMD64)" $<

$(VIRTUALBOX_BOX_DIR)/debian74$(BOX_SUFFIX): debian74.json $(SOURCES)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN74_AMD64)" $<

$(VIRTUALBOX_BOX_DIR)/debian6010$(BOX_SUFFIX): debian6010.json $(SOURCES)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN6010_AMD64)" $<

$(VIRTUALBOX_BOX_DIR)/debian609$(BOX_SUFFIX): debian609.json $(SOURCES)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN609_AMD64)" $<

$(VIRTUALBOX_BOX_DIR)/debian76-i386$(BOX_SUFFIX): debian76-i386.json $(SOURCES)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN76_I386)" $<

$(VIRTUALBOX_BOX_DIR)/debian75-i386$(BOX_SUFFIX): debian75-i386.json $(SOURCES)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN75_I386)" $<

$(VIRTUALBOX_BOX_DIR)/debian74-i386$(BOX_SUFFIX): debian74-i386.json $(SOURCES)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN74_I386)" $<

$(VIRTUALBOX_BOX_DIR)/debian6010-i386$(BOX_SUFFIX): debian6010-i386.json $(SOURCES)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN6010_I386)" $<

$(VIRTUALBOX_BOX_DIR)/debian609-i386$(BOX_SUFFIX): debian609-i386.json $(SOURCES)
	rm -rf $(VIRTUALBOX_OUTPUT)
	mkdir -p $(VIRTUALBOX_BOX_DIR)
	$(PACKER) build -only=$(VIRTUALBOX_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN609_I386)" $<

# Generic rule - not used currently
#$(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX): %.json
#	cd $(dir $<)
#	rm -rf output-virtualbox-iso
#	mkdir -p $(PARALLELS_BOX_DIR)
#	packer build -only=parallels-iso $(PACKER_VARS) $<

$(PARALLELS_BOX_DIR)/debian76$(BOX_SUFFIX): debian76.json $(SOURCES)
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	packer build -only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN76_AMD64)" $<

$(PARALLELS_BOX_DIR)/debian75$(BOX_SUFFIX): debian75.json $(SOURCES)
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	packer build -only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN75_AMD64)" $<

$(PARALLELS_BOX_DIR)/debian74$(BOX_SUFFIX): debian74.json $(SOURCES)
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	packer build -only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN74_AMD64)" $<

$(PARALLELS_BOX_DIR)/debian6010$(BOX_SUFFIX): debian6010.json $(SOURCES)
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	packer build -only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN6010_AMD64)" $<

$(PARALLELS_BOX_DIR)/debian609$(BOX_SUFFIX): debian609.json $(SOURCES)
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	packer build -only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN609_AMD64)" $<

$(PARALLELS_BOX_DIR)/debian76-i386$(BOX_SUFFIX): debian76-i386.json $(SOURCES)
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	packer build -only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN76_I386)" $<

$(PARALLELS_BOX_DIR)/debian75-i386$(BOX_SUFFIX): debian75-i386.json $(SOURCES)
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	packer build -only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN75_I386)" $<

$(PARALLELS_BOX_DIR)/debian74-i386$(BOX_SUFFIX): debian74-i386.json $(SOURCES)
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	packer build -only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN74_I386)" $<

$(PARALLELS_BOX_DIR)/debian6010-i386$(BOX_SUFFIX): debian6010-i386.json $(SOURCES)
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	packer build -only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN6010_I386)" $<

$(PARALLELS_BOX_DIR)/debian609-i386$(BOX_SUFFIX): debian609-i386.json $(SOURCES)
	rm -rf $(PARALLELS_OUTPUT)
	mkdir -p $(PARALLELS_BOX_DIR)
	packer build -only=$(PARALLELS_BUILDER) $(PACKER_VARS) -var "iso_url=$(DEBIAN609_I386)" $<


list:
	@echo "Prepend 'vmware/', 'virtualbox/', or 'parallels/' to build a particular target:"
	@echo "  make vmware/debian76"
	@echo ""
	@echo "Targets;"
	@for shortcut_target in $(SHORTCUT_TARGETS) ; do \
		echo $$shortcut_target ; \
	done ;

validate:
	@for template_filename in $(TEMPLATE_FILENAMES) ; do \
		echo Checking $$template_filename ; \
		packer validate $$template_filename ; \
	done

clean: clean-builders clean-output clean-packer-cache

clean-builders:
	@for builder in $(BUILDER_TYPES) ; do \
		if test -d box/$$builder ; then \
			echo Deleting box/$$builder/*.box ; \
			find box/$$builder -maxdepth 1 -type f -name "*.box" ! -name .gitignore -exec rm '{}' \; ; \
		fi ; \
	done

clean-output:
	@for builder in $(BUILDER_TYPES) ; do \
		echo Deleting output-$$builder-iso ; \
		echo rm -rf output-$$builder-iso ; \
	done

clean-packer-cache:
	echo Deleting packer_cache
	rm -rf packer_cache

test-$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): $(VMWARE_BOX_DIR)/%$(BOX_SUFFIX)
	bin/test-box.sh $< vmware_desktop vmware_fusion $(CURRENT_DIR)/test/*_spec.rb

test-$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): $(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX)
	bin/test-box.sh $< virtualbox virtualbox $(CURRENT_DIR)/test/*_spec.rb

test-$(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX): $(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX)
	bin/test-box.sh $< parallels parallels $(CURRENT_DIR)/test/*_spec.rb

ssh-$(VMWARE_BOX_DIR)/%$(BOX_SUFFIX): $(VMWARE_BOX_DIR)/%$(BOX_SUFFIX)
	bin/ssh-box.sh $< vmware_desktop vmware_fusion $(CURRENT_DIR)/test/*_spec.rb

ssh-$(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX): $(VIRTUALBOX_BOX_DIR)/%$(BOX_SUFFIX)
	bin/ssh-box.sh $< virtualbox virtualbox $(CURRENT_DIR)/test/*_spec.rb

ssh-$(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX): $(PARALLELS_BOX_DIR)/%$(BOX_SUFFIX)
	bin/ssh-box.sh $< parallels parallels $(CURRENT_DIR)/test/*_spec.rb
