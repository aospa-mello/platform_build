# Print a list of the modules that could be built
# Currently runtime_dependencies only include the runtime libs information for cc binaries.

MODULE_INFO_JSON := $(PRODUCT_OUT)/module-info.json

$(MODULE_INFO_JSON):
	@echo Generating $@
	$(foreach m, $(sort $(ALL_MODULES)), $(eval ALL_MODULES.$(m).INCS := \
					$(patsubst -D%,,$(subst -I,,$(foreach imp,$(ALL_MODULES.$(m).IMPORTS), \
					$(EXPORTS.$(imp).FLAGS))) $(ALL_MODULES.$(m).INCS))))
	$(hide) echo -ne '{\n ' > $@
	$(hide) echo -ne $(foreach m, $(sort $(ALL_MODULES)), \
		' "$(m)": {' \
			'"class": [$(foreach w,$(sort $(ALL_MODULES.$(m).CLASS)),"$(w)", )], ' \
			'"path": [$(foreach w,$(sort $(ALL_MODULES.$(m).PATH)),"$(w)", )], ' \
			'"tags": [$(foreach w,$(sort $(ALL_MODULES.$(m).TAGS)),"$(w)", )], ' \
			'"installed": [$(foreach w,$(sort $(ALL_MODULES.$(m).INSTALLED)),"$(w)", )], ' \
			'"compatibility_suites": [$(foreach w,$(sort $(ALL_MODULES.$(m).COMPATIBILITY_SUITES)),"$(w)", )], ' \
			'"auto_test_config": [$(ALL_MODULES.$(m).auto_test_config)], ' \
			'"module_name": "$(ALL_MODULES.$(m).MODULE_NAME)", ' \
			'"test_config": [$(foreach w,$(strip $(ALL_MODULES.$(m).TEST_CONFIG) $(ALL_MODULES.$(m).EXTRA_TEST_CONFIGS)),"$(w)", )], ' \
			'"dependencies": [$(foreach w,$(sort $(ALL_DEPS.$(m).ALL_DEPS)),"$(w)", )], ' \
			'"shared_libs": [$(foreach w,$(sort $(ALL_MODULES.$(m).SHARED_LIBS)),"$(w)", )], ' \
			'"system_shared_libs": [$(foreach w,$(sort $(ALL_MODULES.$(m).SYSTEM_SHARED_LIBS)),"$(w)", )], ' \
			'"srcs": [$(foreach w,$(sort $(ALL_MODULES.$(m).SRCS)),"$(w)", )], ' \
			'"incs": [$(foreach w,$(sort $(ALL_MODULES.$(m).INCS)),"$(w)", )], ' \
                        '"static": [$(foreach w,$(sort $(ALL_MODULES.$(m).STATIC)),"$(w)", )], ' \
                        '"wstatic": [$(foreach w,$(sort $(ALL_MODULES.$(m).WSTATIC)),"$(w)", )], ' \
                        '"export": [$(foreach w,$(sort $(ALL_MODULES.$(m).EXPORT)),"$(w)", )], ' \
                        '"cflags": [$(foreach w,$(sort $(ALL_MODULES.$(m).CFLAGS)),"$(w)", )], ' \
                        '"abi_checker": [$(foreach w,$(sort $(ALL_MODULES.$(m).ABI_CHECKER)),"$(w)", )], ' \
			'"srcjars": [$(foreach w,$(sort $(ALL_MODULES.$(m).SRCJARS)),"$(w)", )], ' \
			'"classes_jar": [$(foreach w,$(sort $(ALL_MODULES.$(m).CLASSES_JAR)),"$(w)", )], ' \
			'"test_mainline_modules": [$(foreach w,$(sort $(ALL_MODULES.$(m).TEST_MAINLINE_MODULES)),"$(w)", )], ' \
			'"is_unit_test": "$(ALL_MODULES.$(m).IS_UNIT_TEST)", ' \
			'"test_options_tags": [$(foreach w,$(sort $(ALL_MODULES.$(m).TEST_OPTIONS_TAGS)),"$(w)", )], ' \
			'"data": [$(foreach w,$(sort $(ALL_MODULES.$(m).TEST_DATA)),"$(w)", )], ' \
			'"runtime_dependencies": [$(foreach w,$(sort $(ALL_MODULES.$(m).LOCAL_RUNTIME_LIBRARIES)),"$(w)", )], ' \
			'"static_dependencies": [$(foreach w,$(sort $(ALL_MODULES.$(m).LOCAL_STATIC_LIBRARIES)),"$(w)", )], ' \
			'"data_dependencies": [$(foreach w,$(sort $(ALL_MODULES.$(m).TEST_DATA_BINS)),"$(w)", )], ' \
			'"supported_variants": [$(foreach w,$(sort $(ALL_MODULES.$(m).SUPPORTED_VARIANTS)),"$(w)", )], ' \
			'"host_dependencies": [$(foreach w,$(sort $(ALL_MODULES.$(m).HOST_REQUIRED_FROM_TARGET)),"$(w)", )], ' \
			'"target_dependencies": [$(foreach w,$(sort $(ALL_MODULES.$(m).TARGET_REQUIRED_FROM_HOST)),"$(w)", )], ' \
			'},\n' \
	 ) | sed -e 's/, *\]/]/g' -e 's/, *\}/ }/g' -e '$$s/,$$//' >> $@
	$(hide) echo '}' >> $@


droidcore-unbundled: $(MODULE_INFO_JSON)

$(call dist-for-goals, general-tests, $(MODULE_INFO_JSON))
$(call dist-for-goals, droidcore-unbundled, $(MODULE_INFO_JSON))

# On every build, generate an all_modules.txt file to be used for autocompleting
# the m command. After timing this using $(shell date +"%s.%3N"), it only adds
# 0.01 seconds to the internal master build, and will only rerun on builds that
# rerun kati.
$(file >$(PRODUCT_OUT)/all_modules.txt,$(subst $(space),$(newline),$(ALL_MODULES)))
