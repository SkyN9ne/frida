include config.mk

build_arch := $(shell releng/detect-arch.sh)
test_args := $(addprefix -p=,$(tests))

HELP_FUN = \
	my (%help, @sections); \
	while(<>) { \
		if (/^([\w-]+)\s*:.*\#\#(?:@([\w-]+))?\s(.*)$$/) { \
			$$section = $$2 // 'options'; \
			push @sections, $$section unless exists $$help{$$section}; \
			push @{$$help{$$section}}, [$$1, $$3]; \
		} \
	} \
	$$target_color = "\033[32m"; \
	$$variable_color = "\033[36m"; \
	$$reset_color = "\033[0m"; \
	print "\n"; \
	print "\033[31mUsage:$${reset_color} make $${target_color}TARGET$${reset_color} [$${variable_color}VARIABLE$${reset_color}=value]\n\n"; \
	print "Where $${target_color}TARGET$${reset_color} specifies one or more of:\n"; \
	print "\n"; \
	for (@sections) { \
		print "  /* $$_ */\n"; $$sep = " " x (30 - length $$_->[0]); \
		printf("  $${target_color}%-30s$${reset_color}    %s\n", $$_->[0], $$_->[1]) for @{$$help{$$_}}; \
		print "\n"; \
	} \
	print "And optionally also $${variable_color}VARIABLE$${reset_color} values:\n"; \
	print "  $${variable_color}PYTHON$${reset_color}                            Absolute path of Python interpreter including version suffix\n"; \
	print "  $${variable_color}NODE$${reset_color}                              Absolute path of Node.js binary\n"; \
	print "\n"; \
	print "For example:\n"; \
	print "  \$$ make $${target_color}python-linux-x86_64 $${variable_color}PYTHON$${reset_color}=/opt/python36-64/bin/python3.6\n"; \
	print "  \$$ make $${target_color}node-linux-x86 $${variable_color}NODE$${reset_color}=/opt/node-linux-x86/bin/node\n"; \
	print "\n";

help:
	@LC_ALL=C perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)


include releng/frida.mk

distclean: clean-submodules
	rm -rf build/
	rm -rf deps/

clean: clean-submodules
	rm -f build/*-clang*
	rm -f build/*-pkg-config
	rm -f build/*-stamp
	rm -f build/*-strip
	rm -f build/*.rc
	rm -f build/*.sh
	rm -f build/*.site
	rm -f build/*.tar.bz2
	rm -f build/*.txt
	rm -f build/frida-version.h
	rm -rf build/frida-*-*
	rm -rf build/frida_thin-*-*
	rm -rf build/frida_gir-*-*
	rm -rf build/fs-*-*
	rm -rf build/ft-*-*
	rm -rf build/tmp-*-*
	rm -rf build/tmp_thin-*-*
	rm -rf build/tmp_gir-*-*
	rm -rf build/fs-tmp-*-*
	rm -rf build/ft-tmp-*-*

clean-submodules:
	cd frida-gum && git clean -xfd
	cd frida-core && git clean -xfd
	cd frida-python && git clean -xfd
	cd frida-node && git clean -xfd
	cd frida-tools && git clean -xfd


gum-linux-x86: build/frida-linux-x86/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for Linux/x86
gum-linux-x86_64: build/frida-linux-x86_64/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for Linux/x86-64
gum-linux-x86-thin: build/frida_thin-linux-x86/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for Linux/x86 without cross-arch support
gum-linux-x86_64-thin: build/frida_thin-linux-x86_64/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for Linux/x86-64 without cross-arch support
gum-linux-x86_64-gir: build/frida_gir-linux-x86_64/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for Linux/x86-64 with shared GLib and GIR
gum-linux-arm: build/frida_thin-linux-arm/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for Linux/arm
gum-linux-armbe8: build/frida_thin-linux-armbe8/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for Linux/armbe8
gum-linux-armhf: build/frida_thin-linux-armhf/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for Linux/armhf
gum-linux-arm64: build/frida_thin-linux-arm64/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for Linux/arm64
gum-linux-mips: build/frida_thin-linux-mips/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for Linux/mips
gum-linux-mipsel: build/frida_thin-linux-mipsel/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for Linux/mipsel
gum-linux-mips64: build/frida_thin-linux-mips64/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for Linux/mips64
gum-linux-mips64el: build/frida_thin-linux-mips64el/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for Linux/MIP64Sel
gum-android-x86: build/frida-android-x86/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for Android/x86
gum-android-x86_64: build/frida-android-x86_64/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for Android/x86-64
gum-android-arm: build/frida-android-arm/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for Android/arm
gum-android-arm64: build/frida-android-arm64/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for Android/arm64
gum-qnx-arm: build/frida_thin-qnx-arm/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for QNX/arm
gum-qnx-armeabi: build/frida_thin-qnx-armeabi/lib/pkgconfig/frida-gum-1.0.pc ##@gum Build for QNX/armeabi


define make-gum-rules
build/$1-%/lib/pkgconfig/frida-gum-1.0.pc: build/$1-env-%.rc build/.frida-gum-submodule-stamp
	. build/$1-env-$$*.rc; \
	builddir=build/$2-$$*/frida-gum; \
	if [ ! -f $$$$builddir/build.ninja ]; then \
		$$(call meson-setup-for-env,$1,$$*) \
			--prefix $$(FRIDA)/build/$1-$$* \
			--libdir $$(FRIDA)/build/$1-$$*/lib \
			$$(frida_gum_flags) \
			frida-gum $$$$builddir || exit 1; \
	fi; \
	$$(MESON) install -C $$$$builddir || exit 1
	@touch -c $$@
endef
$(eval $(call make-gum-rules,frida,tmp))
$(eval $(call make-gum-rules,frida_thin,tmp_thin))
$(eval $(call make-gum-rules,frida_gir,tmp_gir))

check-gum-linux-x86: gum-linux-x86 ##@gum Run tests for Linux/x86
	build/tmp-linux-x86/frida-gum/tests/gum-tests $(test_args)
check-gum-linux-x86_64: gum-linux-x86_64 ##@gum Run tests for Linux/x86-64
	build/tmp-linux-x86_64/frida-gum/tests/gum-tests $(test_args)
check-gum-linux-x86-thin: gum-linux-x86-thin ##@gum Run tests for Linux/x86 without cross-arch support
	build/tmp_thin-linux-x86/frida-gum/tests/gum-tests $(test_args)
check-gum-linux-x86_64-thin: gum-linux-x86_64-thin ##@gum Run tests for Linux/x86-64 without cross-arch support
	build/tmp_thin-linux-x86_64/frida-gum/tests/gum-tests $(test_args)
check-gum-linux-armhf: gum-linux-armhf ##@gum Run tests for Linux/armhf
	build/tmp_thin-linux-armhf/frida-gum/tests/gum-tests $(test_args)
check-gum-linux-arm64: gum-linux-arm64 ##@gum Run tests for Linux/arm64
	build/tmp_thin-linux-arm64/frida-gum/tests/gum-tests $(test_args)


core-linux-x86: build/frida-linux-x86/lib/pkgconfig/frida-core-1.0.pc ##@core Build for Linux/x86
core-linux-x86_64: build/frida-linux-x86_64/lib/pkgconfig/frida-core-1.0.pc ##@core Build for Linux/x86-64
core-linux-x86-thin: build/frida_thin-linux-x86/lib/pkgconfig/frida-core-1.0.pc ##@core Build for Linux/x86 without cross-arch support
core-linux-x86_64-thin: build/frida_thin-linux-x86_64/lib/pkgconfig/frida-core-1.0.pc ##@core Build for Linux/x86-64 without cross-arch support
core-linux-arm: build/frida_thin-linux-arm/lib/pkgconfig/frida-core-1.0.pc ##@core Build for Linux/arm
core-linux-armbe8: build/frida_thin-linux-armbe8/lib/pkgconfig/frida-core-1.0.pc ##@core Build for Linux/armbe8
core-linux-armhf: build/frida_thin-linux-armhf/lib/pkgconfig/frida-core-1.0.pc ##@core Build for Linux/armhf
core-linux-arm64: build/frida_thin-linux-arm64/lib/pkgconfig/frida-core-1.0.pc ##@core Build for Linux/arm64
core-linux-mips: build/frida_thin-linux-mips/lib/pkgconfig/frida-core-1.0.pc ##@core Build for Linux/mips
core-linux-mipsel: build/frida_thin-linux-mipsel/lib/pkgconfig/frida-core-1.0.pc ##@core Build for Linux/mipsel
core-linux-mips64: build/frida_thin-linux-mips64/lib/pkgconfig/frida-core-1.0.pc ##@core Build for Linux/mips64
core-linux-mips64el: build/frida_thin-linux-mips64el/lib/pkgconfig/frida-core-1.0.pc ##@core Build for Linux/mips64el
core-android-x86: build/frida-android-x86/lib/pkgconfig/frida-core-1.0.pc ##@core Build for Android/x86
core-android-x86_64: build/frida-android-x86_64/lib/pkgconfig/frida-core-1.0.pc ##@core Build for Android/x86-64
core-android-arm: build/frida-android-arm/lib/pkgconfig/frida-core-1.0.pc ##@core Build for Android/arm
core-android-arm64: build/frida-android-arm64/lib/pkgconfig/frida-core-1.0.pc ##@core Build for Android/arm64
core-qnx-arm: build/frida_thin-qnx-arm/lib/pkgconfig/frida-core-1.0.pc ##@core Build for QNX/arm
core-qnx-armeabi: build/frida_thin-qnx-armeabi/lib/pkgconfig/frida-core-1.0.pc ##@core Build for QNX/armeabi

build/tmp-linux-x86/frida-core/.frida-ninja-stamp: build/.frida-core-submodule-stamp build/frida-linux-x86/lib/pkgconfig/frida-gum-1.0.pc
	. build/frida-env-linux-x86.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,linux-x86) \
			--prefix $(FRIDA)/build/frida-linux-x86 \
			--libdir $(FRIDA)/build/frida-linux-x86/lib \
			$(frida_core_flags) \
			frida-core $$builddir || exit 1; \
	fi
	@touch $@
build/tmp-linux-x86_64/frida-core/.frida-ninja-stamp: build/.frida-core-submodule-stamp build/frida-linux-x86_64/lib/pkgconfig/frida-gum-1.0.pc
	. build/frida-env-linux-x86_64.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,linux-x86_64) \
			--prefix $(FRIDA)/build/frida-linux-x86_64 \
			--libdir $(FRIDA)/build/frida-linux-x86_64/lib \
			$(frida_core_flags) \
			-Dhelper_modern=$(FRIDA)/build/tmp-linux-x86_64/frida-core/src/frida-helper \
			-Dhelper_legacy=$(FRIDA)/build/tmp-linux-x86/frida-core/src/frida-helper \
			-Dagent_modern=$(FRIDA)/build/tmp-linux-x86_64/frida-core/lib/agent/frida-agent.so \
			-Dagent_legacy=$(FRIDA)/build/tmp-linux-x86/frida-core/lib/agent/frida-agent.so \
			frida-core $$builddir || exit 1; \
	fi
	@touch $@
build/tmp-android-x86/frida-core/.frida-ninja-stamp: build/.frida-core-submodule-stamp build/frida-android-x86/lib/pkgconfig/frida-gum-1.0.pc
	if [ "$(FRIDA_AGENT_EMULATED)" == "yes" ]; then \
		agent_emulated_legacy=$(FRIDA)/build/tmp-android-arm/frida-core/lib/agent/frida-agent.so; \
	fi; \
	. build/frida-env-android-x86.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,android-x86) \
			--prefix $(FRIDA)/build/frida-android-x86 \
			--libdir $(FRIDA)/build/frida-android-x86/lib \
			$(frida_core_flags) \
			-Dagent_emulated_legacy=$$agent_emulated_legacy \
			frida-core $$builddir || exit 1; \
	fi
	@touch $@
build/tmp-android-x86_64/frida-core/.frida-ninja-stamp: build/.frida-core-submodule-stamp build/frida-android-x86_64/lib/pkgconfig/frida-gum-1.0.pc
	if [ "$(FRIDA_AGENT_EMULATED)" == "yes" ]; then \
		agent_emulated_modern=$(FRIDA)/build/tmp-android-arm64/frida-core/lib/agent/frida-agent.so; \
		agent_emulated_legacy=$(FRIDA)/build/tmp-android-arm/frida-core/lib/agent/frida-agent.so; \
	fi; \
	. build/frida-env-android-x86_64.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,android-x86_64) \
			--prefix $(FRIDA)/build/frida-android-x86_64 \
			--libdir $(FRIDA)/build/frida-android-x86_64/lib \
			$(frida_core_flags) \
			-Dhelper_modern=$(FRIDA)/build/tmp-android-x86_64/frida-core/src/frida-helper \
			-Dhelper_legacy=$(FRIDA)/build/tmp-android-x86/frida-core/src/frida-helper \
			-Dagent_modern=$(FRIDA)/build/tmp-android-x86_64/frida-core/lib/agent/frida-agent.so \
			-Dagent_legacy=$(FRIDA)/build/tmp-android-x86/frida-core/lib/agent/frida-agent.so \
			-Dagent_emulated_modern=$$agent_emulated_modern \
			-Dagent_emulated_legacy=$$agent_emulated_legacy \
			frida-core $$builddir || exit 1; \
	fi
	@touch $@
build/tmp-android-arm/frida-core/.frida-ninja-stamp: build/.frida-core-submodule-stamp build/frida-android-arm/lib/pkgconfig/frida-gum-1.0.pc
	. build/frida-env-android-arm.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,android-arm) \
			--prefix $(FRIDA)/build/frida-android-arm \
			--libdir $(FRIDA)/build/frida-android-arm/lib \
			$(frida_core_flags) \
			frida-core $$builddir || exit 1; \
	fi
	@touch $@
build/tmp-android-arm64/frida-core/.frida-ninja-stamp: build/.frida-core-submodule-stamp build/frida-android-arm64/lib/pkgconfig/frida-gum-1.0.pc
	. build/frida-env-android-arm64.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup,android-arm64) \
			--prefix $(FRIDA)/build/frida-android-arm64 \
			--libdir $(FRIDA)/build/frida-android-arm64/lib \
			$(frida_core_flags) \
			-Dhelper_modern=$(FRIDA)/build/tmp-android-arm64/frida-core/src/frida-helper \
			-Dhelper_legacy=$(FRIDA)/build/tmp-android-arm/frida-core/src/frida-helper \
			-Dagent_modern=$(FRIDA)/build/tmp-android-arm64/frida-core/lib/agent/frida-agent.so \
			-Dagent_legacy=$(FRIDA)/build/tmp-android-arm/frida-core/lib/agent/frida-agent.so \
			frida-core $$builddir || exit 1; \
	fi
	@touch $@
build/tmp_thin-%/frida-core/.frida-ninja-stamp: build/.frida-core-submodule-stamp build/frida_thin-%/lib/pkgconfig/frida-gum-1.0.pc
	. build/frida_thin-env-$*.rc; \
	builddir=$(@D); \
	if [ ! -f $$builddir/build.ninja ]; then \
		$(call meson-setup-thin,$*) \
			--prefix $(FRIDA)/build/frida_thin-$* \
			--libdir $(FRIDA)/build/frida_thin-$*/lib \
			$(frida_core_flags) \
			frida-core $$builddir || exit 1; \
	fi
	@touch $@

ifeq ($(FRIDA_AGENT_EMULATED), yes)
legacy_agent_emulated_dep := build/tmp-android-arm/frida-core/.frida-agent-stamp
modern_agent_emulated_dep := build/tmp-android-arm64/frida-core/.frida-agent-stamp
endif

build/frida-linux-x86/lib/pkgconfig/frida-core-1.0.pc: build/tmp-linux-x86/frida-core/.frida-helper-and-agent-stamp
	@rm -f build/tmp-linux-x86/frida-core/src/frida-data-{helper,agent}*
	. build/frida-env-linux-x86.rc && $(MESON) install -C build/tmp-linux-x86/frida-core
	@touch $@
build/frida-linux-x86_64/lib/pkgconfig/frida-core-1.0.pc: build/tmp-linux-x86/frida-core/.frida-helper-and-agent-stamp build/tmp-linux-x86_64/frida-core/.frida-helper-and-agent-stamp
	@rm -f build/tmp-linux-x86_64/frida-core/src/frida-data-{helper,agent}*
	. build/frida-env-linux-x86_64.rc && $(MESON) install -C build/tmp-linux-x86_64/frida-core
	@touch $@
build/frida-android-x86/lib/pkgconfig/frida-core-1.0.pc: build/tmp-android-x86/frida-core/.frida-helper-and-agent-stamp $(legacy_agent_emulated_dep)
	@rm -f build/tmp-android-x86/frida-core/src/frida-data-{helper,agent}*
	. build/frida-env-android-x86.rc && $(MESON) install -C build/tmp-android-x86/frida-core
	@touch $@
build/frida-android-x86_64/lib/pkgconfig/frida-core-1.0.pc: build/tmp-android-x86/frida-core/.frida-helper-and-agent-stamp build/tmp-android-x86_64/frida-core/.frida-helper-and-agent-stamp $(legacy_agent_emulated_dep) $(modern_agent_emulated_dep)
	@rm -f build/tmp-android-x86_64/frida-core/src/frida-data-{helper,agent}*
	. build/frida-env-android-x86_64.rc && $(MESON) install -C build/tmp-android-x86_64/frida-core
	@touch $@
build/frida-android-arm/lib/pkgconfig/frida-core-1.0.pc: build/tmp-android-arm/frida-core/.frida-helper-and-agent-stamp
	@rm -f build/tmp-android-arm/frida-core/src/frida-data-{helper,agent}*
	. build/frida-env-android-arm.rc && $(MESON) install -C build/tmp-android-arm/frida-core
	@touch $@
build/frida-android-armbe8/lib/pkgconfig/frida-core-1.0.pc: build/tmp-android-armbe8/frida-core/.frida-helper-and-agent-stamp
	@rm -f build/tmp-android-armbe8/frida-core/src/frida-data-{helper,agent}*
	. build/frida-env-android-armbe8.rc && $(MESON) install -C build/tmp-android-armbe8/frida-core
	@touch $@
build/frida-android-arm64/lib/pkgconfig/frida-core-1.0.pc: build/tmp-android-arm/frida-core/.frida-helper-and-agent-stamp build/tmp-android-arm64/frida-core/.frida-helper-and-agent-stamp
	@rm -f build/tmp-android-arm64/frida-core/src/frida-data-{helper,agent}*
	. build/frida-env-android-arm64.rc && $(MESON) install -C build/tmp-android-arm64/frida-core
	@touch $@
build/frida_thin-%/lib/pkgconfig/frida-core-1.0.pc: build/tmp_thin-%/frida-core/.frida-ninja-stamp
	. build/frida_thin-env-$*.rc && $(MESON) install -C build/tmp_thin-$*/frida-core
	@touch $@

build/tmp-%/frida-core/.frida-helper-and-agent-stamp: build/tmp-%/frida-core/.frida-ninja-stamp
	. build/frida-env-$*.rc && ninja -C build/tmp-$*/frida-core src/frida-helper lib/agent/frida-agent.so
	@touch $@
build/tmp-%/frida-core/.frida-agent-stamp: build/tmp-%/frida-core/.frida-ninja-stamp
	. build/frida-env-$*.rc && ninja -C build/tmp-$*/frida-core lib/agent/frida-agent.so
	@touch $@

check-core-linux-x86: core-linux-x86 ##@core Run tests for Linux/x86
	build/tmp-linux-x86/frida-core/tests/frida-tests $(test_args)
check-core-linux-x86_64: core-linux-x86_64 ##@core Run tests for Linux/x86-64
	build/tmp-linux-x86_64/frida-core/tests/frida-tests $(test_args)
check-core-linux-x86-thin: core-linux-x86-thin ##@core Run tests for Linux/x86 without cross-arch support
	build/tmp_thin-linux-x86/frida-core/tests/frida-tests $(test_args)
check-core-linux-x86_64-thin: core-linux-x86_64-thin ##@core Run tests for Linux/x86-64 without cross-arch support
	build/tmp_thin-linux-x86_64/frida-core/tests/frida-tests $(test_args)
check-core-linux-armhf: core-linux-armhf ##@core Run tests for Linux/armhf
	build/tmp_thin-linux-armhf/frida-core/tests/frida-tests $(test_args)
check-core-linux-arm64: core-linux-arm64 ##@core Run tests for Linux/arm64
	build/tmp_thin-linux-arm64/frida-core/tests/frida-tests $(test_args)


python-linux-x86: build/tmp-linux-x86/frida-$(PYTHON_NAME)/.frida-stamp ##@python Build Python bindings for Linux/x86
python-linux-x86_64: build/tmp-linux-x86_64/frida-$(PYTHON_NAME)/.frida-stamp ##@python Build Python bindings for Linux/x86-64
python-linux-x86-thin: build/tmp_thin-linux-x86/frida-$(PYTHON_NAME)/.frida-stamp ##@python Build Python bindings for Linux/x86 without cross-arch support
python-linux-x86_64-thin: build/tmp_thin-linux-x86_64/frida-$(PYTHON_NAME)/.frida-stamp ##@python Build Python bindings for Linux/x86-64 without cross-arch support
python-linux-armhf: build/tmp_thin-linux-armhf/frida-$(PYTHON_NAME)/.frida-stamp ##@python Build Python bindings for Linux/armhf
python-linux-arm64: build/tmp_thin-linux-arm64/frida-$(PYTHON_NAME)/.frida-stamp ##@python Build Python bindings for Linux/arm64

define make-python-rule
build/$2-%/frida-$$(PYTHON_NAME)/.frida-stamp: build/.frida-python-submodule-stamp build/$1-%/lib/pkgconfig/frida-core-1.0.pc
	. build/$1-env-$$*.rc; \
	builddir=$$(@D); \
	if [ ! -f $$$$builddir/build.ninja ]; then \
		$$(call meson-setup-for-env,$1,$$*) \
			--prefix $$(FRIDA)/build/$1-$$* \
			--libdir $$(FRIDA)/build/$1-$$*/lib \
			-Dpython=$$(PYTHON) \
			-Dpython_incdir=$$(PYTHON_INCDIR) \
			frida-python $$$$builddir || exit 1; \
	fi; \
	$$(MESON) install -C $$$$builddir || exit 1; \
	$$$$STRIP $$$$STRIP_FLAGS build/$1-$$*/lib/$$(PYTHON_NAME)/site-packages/_frida.so
	@touch $$@
endef
$(eval $(call make-python-rule,frida,tmp))
$(eval $(call make-python-rule,frida_thin,tmp_thin))

check-python-linux-x86: build/tmp-linux-x86/frida-$(PYTHON_NAME)/.frida-stamp ##@python Test Python bindings for Linux/x86
	export PYTHONPATH="$(shell pwd)/build/frida-linux-x86/lib/$(PYTHON_NAME)/site-packages" \
		&& cd frida-python \
		&& ${PYTHON} -m unittest discover
check-python-linux-x86_64: build/tmp-linux-x86_64/frida-$(PYTHON_NAME)/.frida-stamp ##@python Test Python bindings for Linux/x86-64
	export PYTHONPATH="$(shell pwd)/build/frida-linux-x86_64/lib/$(PYTHON_NAME)/site-packages" \
		&& cd frida-python \
		&& ${PYTHON} -m unittest discover
check-python-linux-x86-thin: build/tmp_thin-linux-x86/frida-$(PYTHON_NAME)/.frida-stamp ##@python Test Python bindings for Linux/x86 without cross-arch support
	export PYTHONPATH="$(shell pwd)/build/frida_thin-linux-x86/lib/$(PYTHON_NAME)/site-packages" \
		&& cd frida-python \
		&& ${PYTHON} -m unittest discover
check-python-linux-x86_64-thin: build/tmp_thin-linux-x86_64/frida-$(PYTHON_NAME)/.frida-stamp ##@python Test Python bindings for Linux/x86-64 without cross-arch support
	export PYTHONPATH="$(shell pwd)/build/frida_thin-linux-x86_64/lib/$(PYTHON_NAME)/site-packages" \
		&& cd frida-python \
		&& ${PYTHON} -m unittest discover
check-python-linux-armhf: build/tmp_thin-linux-armhf/frida-$(PYTHON_NAME)/.frida-stamp ##@python Test Python bindings for Linux/armhf
	export PYTHONPATH="$(shell pwd)/build/frida_thin-linux-armhf/lib/$(PYTHON_NAME)/site-packages" \
		&& cd frida-python \
		&& ${PYTHON} -m unittest discover
check-python-linux-arm64: build/tmp_thin-linux-arm64/frida-$(PYTHON_NAME)/.frida-stamp ##@python Test Python bindings for Linux/arm64
	export PYTHONPATH="$(shell pwd)/build/frida_thin-linux-arm64/lib/$(PYTHON_NAME)/site-packages" \
		&& cd frida-python \
		&& ${PYTHON} -m unittest discover


node-linux-x86: build/frida-linux-x86/lib/node_modules/frida build/.frida-node-submodule-stamp ##@node Build Node.js bindings for Linux/x86
node-linux-x86_64: build/frida-linux-x86_64/lib/node_modules/frida build/.frida-node-submodule-stamp ##@node Build Node.js bindings for Linux/x86-64
node-linux-x86-thin: build/frida_thin-linux-x86/lib/node_modules/frida build/.frida-node-submodule-stamp ##@node Build Node.js bindings for Linux/x86 without cross-arch support
node-linux-x86_64-thin: build/frida_thin-linux-x86_64/lib/node_modules/frida build/.frida-node-submodule-stamp ##@node Build Node.js bindings for Linux/x86-64 without cross-arch support
node-linux-armhf: build/frida_thin-linux-armhf/lib/node_modules/frida build/.frida-node-submodule-stamp ##@node Build Node.js bindings for Linux/armhf
node-linux-arm64: build/frida_thin-linux-arm64/lib/node_modules/frida build/.frida-node-submodule-stamp ##@node Build Node.js bindings for Linux/arm64

define make-node-rule
build/$1-%/lib/node_modules/frida: build/$1-%/lib/pkgconfig/frida-core-1.0.pc build/.frida-node-submodule-stamp
	@$$(NPM) --version &>/dev/null || (echo -e "\033[31mOops. It appears Node.js is not installed.\nCheck PATH or set NODE to the absolute path of your Node.js binary.\033[0m"; exit 1;)
	export PATH=$$(NODE_BIN_DIR):$$$$PATH FRIDA=$$(FRIDA) \
		&& cd frida-node \
		&& rm -rf frida-0.0.0.tgz build node_modules \
		&& $$(NPM) install \
		&& $$(NPM) pack \
		&& rm -rf ../$$@/ ../$$@.tmp/ \
		&& mkdir -p ../$$@.tmp/build/ \
		&& tar -C ../$$@.tmp/ --strip-components 1 -x -f frida-0.0.0.tgz \
		&& rm frida-0.0.0.tgz \
		&& mv build/Release/frida_binding.node ../$$@.tmp/build/ \
		&& rm -rf build \
		&& mv node_modules ../$$@.tmp/ \
		&& strip --strip-all ../$$@.tmp/build/frida_binding.node \
		&& mv ../$$@.tmp ../$$@
endef
$(eval $(call make-node-rule,frida,tmp))
$(eval $(call make-node-rule,frida_thin,tmp_thin))

define run-node-tests
	export PATH=$3:$$PATH FRIDA=$2 \
		&& cd frida-node \
		&& git clean -xfd \
		&& $5 install \
		&& $4 \
			--expose-gc \
			../build/$1/lib/node_modules/frida/node_modules/.bin/_mocha \
			-r ts-node/register \
			--timeout 60000 \
			test/*.ts
endef
check-node-linux-x86: node-linux-x86 ##@node Test Node.js bindings for Linux/x86
	$(call run-node-tests,frida-linux-x86,$(FRIDA),$(NODE_BIN_DIR),$(NODE),$(NPM))
check-node-linux-x86_64: node-linux-x86_64 ##@node Test Node.js bindings for Linux/x86-64
	$(call run-node-tests,frida-linux-x86_64,$(FRIDA),$(NODE_BIN_DIR),$(NODE),$(NPM))
check-node-linux-x86-thin: node-linux-x86-thin ##@node Test Node.js bindings for Linux/x86 without cross-arch support
	$(call run-node-tests,frida_thin-linux-x86,$(FRIDA),$(NODE_BIN_DIR),$(NODE),$(NPM))
check-node-linux-x86_64-thin: node-linux-x86_64-thin ##@node Test Node.js bindings for Linux/x86-64 without cross-arch support
	$(call run-node-tests,frida_thin-linux-x86_64,$(FRIDA),$(NODE_BIN_DIR),$(NODE),$(NPM))
check-node-linux-armhf: node-linux-armhf ##@node Test Node.js bindings for Linux/armhf
	$(call run-node-tests,frida_thin-linux-armhf,$(FRIDA),$(NODE_BIN_DIR),$(NODE),$(NPM))
check-node-linux-arm64: node-linux-arm64 ##@node Test Node.js bindings for Linux/arm64
	$(call run-node-tests,frida_thin-linux-arm64,$(FRIDA),$(NODE_BIN_DIR),$(NODE),$(NPM))


tools-linux-x86: build/tmp-linux-x86/frida-tools-$(PYTHON_NAME)/.frida-stamp ##@tools Build CLI tools for Linux/x86
tools-linux-x86_64: build/tmp-linux-x86_64/frida-tools-$(PYTHON_NAME)/.frida-stamp ##@tools Build CLI tools for Linux/x86-64
tools-linux-x86-thin: build/tmp_thin-linux-x86/frida-tools-$(PYTHON_NAME)/.frida-stamp ##@tools Build CLI tools for Linux/x86 without cross-arch support
tools-linux-x86_64-thin: build/tmp_thin-linux-x86_64/frida-tools-$(PYTHON_NAME)/.frida-stamp ##@tools Build CLI tools for Linux/x86-64 without cross-arch support
tools-linux-armhf: build/tmp_thin-linux-armhf/frida-tools-$(PYTHON_NAME)/.frida-stamp ##@tools Build CLI tools for Linux/armhf
tools-linux-arm64: build/tmp_thin-linux-arm64/frida-tools-$(PYTHON_NAME)/.frida-stamp ##@tools Build CLI tools for Linux/arm64

define make-tools-rule
build/$2-%/frida-tools-$$(PYTHON_NAME)/.frida-stamp: build/.frida-tools-submodule-stamp build/$2-%/frida-$$(PYTHON_NAME)/.frida-stamp
	. build/$1-env-$$*.rc; \
	builddir=$$(@D); \
	if [ ! -f $$$$builddir/build.ninja ]; then \
		$$(call meson-setup-for-env,$1,$$*) \
			--prefix $$(FRIDA)/build/$1-$$* \
			--libdir $$(FRIDA)/build/$1-$$*/lib \
			-Dpython=$$(PYTHON) \
			frida-tools $$$$builddir || exit 1; \
	fi; \
	$$(MESON) install -C $$$$builddir || exit 1
	@touch $$@
endef
$(eval $(call make-tools-rule,frida,tmp))
$(eval $(call make-tools-rule,frida_thin,tmp_thin))

check-tools-linux-x86: build/tmp-linux-x86/frida-tools-$(PYTHON_NAME)/.frida-stamp ##@tools Test CLI tools for Linux/x86
	export PYTHONPATH="$(shell pwd)/build/frida-linux-x86/lib/$(PYTHON_NAME)/site-packages" \
		&& cd frida-tools \
		&& ${PYTHON} -m unittest discover
check-tools-linux-x86_64: build/tmp-linux-x86_64/frida-tools-$(PYTHON_NAME)/.frida-stamp ##@tools Test CLI tools for Linux/x86-64
	export PYTHONPATH="$(shell pwd)/build/frida-linux-x86_64/lib/$(PYTHON_NAME)/site-packages" \
		&& cd frida-tools \
		&& ${PYTHON} -m unittest discover
check-tools-linux-x86-thin: build/tmp_thin-linux-x86/frida-tools-$(PYTHON_NAME)/.frida-stamp ##@tools Test CLI tools for Linux/x86 without cross-arch support
	export PYTHONPATH="$(shell pwd)/build/frida_thin-linux-x86/lib/$(PYTHON_NAME)/site-packages" \
		&& cd frida-tools \
		&& ${PYTHON} -m unittest discover
check-tools-linux-x86_64-thin: build/tmp_thin-linux-x86_64/frida-tools-$(PYTHON_NAME)/.frida-stamp ##@tools Test CLI tools for Linux/x86-64 without cross-arch support
	export PYTHONPATH="$(shell pwd)/build/frida_thin-linux-x86_64/lib/$(PYTHON_NAME)/site-packages" \
		&& cd frida-tools \
		&& ${PYTHON} -m unittest discover
check-tools-linux-armhf: build/tmp_thin-linux-armhf/frida-tools-$(PYTHON_NAME)/.frida-stamp ##@tools Test CLI tools for Linux/armhf
	export PYTHONPATH="$(shell pwd)/build/frida_thin-linux-armhf/lib/$(PYTHON_NAME)/site-packages" \
		&& cd frida-tools \
		&& ${PYTHON} -m unittest discover
check-tools-linux-arm64: build/tmp_thin-linux-arm64/frida-tools-$(PYTHON_NAME)/.frida-stamp ##@tools Test CLI tools for Linux/arm64
	export PYTHONPATH="$(shell pwd)/build/frida_thin-linux-arm64/lib/$(PYTHON_NAME)/site-packages" \
		&& cd frida-tools \
		&& ${PYTHON} -m unittest discover


.PHONY: \
	help \
	distclean clean clean-submodules git-submodules git-submodule-stamps \
	gum-linux-x86 gum-linux-x86_64 \
		gum-linux-x86-thin gum-linux-x86_64-thin gum-linux-x86_64-gir \
		gum-linux-arm gum-linux-armbe8 gum-linux-armhf gum-linux-arm64 \
		gum-linux-mips gum-linux-mipsel \
		gum-linux-mips64 gum-linux-mips64el \
		gum-android-x86 gum-android-x86_64 \
		gum-android-arm gum-android-arm64 \
		gum-qnx-arm gum-qnx-armeabi \
		check-gum-linux-x86 check-gum-linux-x86_64 \
		check-gum-linux-x86-thin check-gum-linux-x86_64-thin \
		check-gum-linux-armhf check-gum-linux-arm64 \
		frida-gum-update-submodule-stamp \
	core-linux-x86 core-linux-x86_64 \
		core-linux-x86-thin core-linux-x86_64-thin \
		core-linux-arm core-linux-armbe8 core-linux-armhf core-linux-arm64 \
		core-linux-mips core-linux-mipsel \
		core-linux-mips64 core-linux-mips64el \
		core-android-x86 core-android-x86_64 \
		core-android-arm core-android-arm64 \
		core-qnx-arm core-qnx-armeabi \
		check-core-linux-x86 check-core-linux-x86_64 \
		check-core-linux-x86-thin check-core-linux-x86_64-thin \
		check-core-linux-armhf check-core-linux-arm64 \
		frida-core-update-submodule-stamp \
	python-linux-x86 python-linux-x86_64 \
		python-linux-x86-thin python-linux-x86_64-thin \
		python-linux-armhf python-linux-arm64 \
		check-python-linux-x86 check-python-linux-x86_64 \
		check-python-linux-x86-thin check-python-linux-x86_64-thin \
		check-python-linux-armhf check-python-linux-arm64 \
		frida-python-update-submodule-stamp \
	node-linux-x86 node-linux-x86_64 \
		node-linux-x86-thin node-linux-x86_64-thin \
		node-linux-armhf node-linux-arm64 \
		check-node-linux-x86 check-node-linux-x86_64 \
		check-node-linux-x86-thin check-node-linux-x86_64-thin \
		check-node-linux-armhf check-node-linux-arm64 \
		frida-node-update-submodule-stamp \
	tools-linux-x86 tools-linux-x86_64 \
		tools-linux-x86-thin tools-linux-x86_64-thin \
		tools-linux-armhf tools-linux-arm64 \
		check-tools-linux-x86 check-tools-linux-x86_64 \
		check-tools-linux-x86-thin check-tools-linux-x86_64-thin \
		check-tools-linux-armhf check-tools-linux-arm64 \
		frida-tools-update-submodule-stamp
.SECONDARY:
