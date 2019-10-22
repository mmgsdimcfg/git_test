MAKEFLAGS += --no-print-directory

KBUILD_KCONFIG = config/Kconfig
KCONFIG_CONFIG = .config
KCONFIG_AUTOCONFIG = auto.conf
KCONFIG_AUTOHEADER = autoconf.h
export KCONFIG_AUTOCONFIG KCONFIG_AUTOHEADER

NUMCPUS=`grep -c '^processor' /proc/cpuinfo`

obj	= $(shell pwd)/config/kconfig

all: boot tz rpm modem linux bin prebuilt

all_d: boot tz rpm modem linux_d bin prebuilt

boot: $(KCONFIG_AUTOCONFIG)
	@cd boot_images; ./build.sh

tz: $(KCONFIG_AUTOCONFIG)
	@cd trustzone_images; ./build.sh

rpm: $(KCONFIG_AUTOCONFIG)
	@cd rpm_proc; ./build.sh

modem: $(KCONFIG_AUTOCONFIG)
	@cd modem_proc; ./build.sh

linux: $(KCONFIG_AUTOCONFIG)
	@cd LINUX/android; ./build.sh -v user -j $(NUMCPUS)

linux_d: $(KCONFIG_AUTOCONFIG)
	@cd LINUX/android; ./build.sh -v userdebug -j $(NUMCPUS)

bin: $(KCONFIG_AUTOCONFIG)
	@cd common; ./build.sh

prebuilt: $(KCONFIG_AUTOCONFIG)
	@cd boot_images; ./build.sh -p
	@cd modem_proc; ./build.sh -p
	@cd rpm_proc; ./build.sh -p
	@cd trustzone_images/; ./build.sh -p

$(KCONFIG_AUTOCONFIG): $(obj)/conf $(KCONFIG_CONFIG)
	@$< --silentoldconfig $(KBUILD_KCONFIG)

$(KCONFIG_CONFIG): $(obj)/mconf
	@[ -f $(KCONFIG_CONFIG) ] || $< $(KBUILD_KCONFIG)

menuconfig: $(obj)/mconf
	@$< $(KBUILD_KCONFIG)
	@$(MAKE) $(KCONFIG_AUTOCONFIG)

nconfig: $(obj)/nconf
	@$< $(KBUILD_KCONFIG)
	@$(MAKE) $(KCONFIG_AUTOCONFIG)

config: $(obj)/conf
	@$< --oldaskconfig $(KBUILD_KCONFIG)
	@$(MAKE) $(KCONFIG_AUTOCONFIG)

oldconfig: $(obj)/conf
	@$< --$@ $(KBUILD_KCONFIG)
	@$(MAKE) $(KCONFIG_AUTOCONFIG)

$(obj)/conf:
	@$(MAKE) -C "$(obj)" conf

$(obj)/mconf:
	@$(MAKE) -C "$(obj)" mconf

$(obj)/nconf:
	@$(MAKE) -C "$(obj)" nconf

distclean_all: clean
	@$(MAKE) -C "$(obj)" clean
	@rm -f $(KCONFIG_CONFIG)
	@rm -f $(KCONFIG_CONFIG).old
	@rm -f $(KCONFIG_AUTOCONFIG)
	@rm -f $(KCONFIG_AUTOHEADER)

distclean: modem_clean linux_clean bin_clean
	@$(MAKE) -C "$(obj)" clean
	@rm -f $(KCONFIG_CONFIG)
	@rm -f $(KCONFIG_CONFIG).old
	@rm -f $(KCONFIG_AUTOCONFIG)
	@rm -f $(KCONFIG_AUTOHEADER)

clean: boot_clean tz_clean rpm_clean modem_clean bin_clean linux_clean

boot_clean:
	@cd boot_images; ./clean.sh

tz_clean:
	@cd trustzone_images; ./clean.sh

rpm_clean:
	@cd rpm_proc; ./clean.sh

modem_clean:
	@cd modem_proc; ./clean.sh

bin_clean:
	@cd common; ./clean.sh

linux_clean:
	@rm -rf LINUX/android/out 

help:
	@echo 'Build:'
	@echo '  all                    - make world'
	@echo '  boot                   - build SBL binaries'
	@echo '  tz                     - build TZ binary'
	@echo '  rpm                    - build RPM binary'
	@echo '  modem                  - build MODEM binaries'
	@echo '  linux                  - build android binaries'
	@echo
	@echo 'Cleaning:'
	@echo '  clean                  - delete all files created by build'
	@echo '  distclean_all          - delete all non-source files (including .config)'
	@echo '  distclean              - delete MODEM, COMMON, LINUX non-source files (including .config)'
	@echo '  boot_clean             - delete all files created by SBL build'
	@echo '  tz_clean               - delete all files created by TZ build'
	@echo '  rpm_clean              - delete all files created by RPM build'
	@echo '  modem_clean            - delete all files created by MODEM build'
	@echo '  linux_clean            - delete all files created by LINUX build'
	@echo '  bin_clean              - delete all files created by COMMON build'
	@echo
	@echo 'Configuration:'
	@echo '  menuconfig             - interactive curses-based configurator'
	@echo '  nconfig                - interactive ncurses-based configurator'
	@echo '  config                 - interactive line-oriented configurator'
	@echo '  oldconfig              - resolve any unresolved symbols in .config'
	@echo

