ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
TARGET := iphone:clang:16.2:15.0
else
TARGET := iphone:clang:14.5:8.0
endif

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = NotRecordingPrefs
NotRecordingPrefs_FILES = NRECListController.m NRECRootListController.m ../Shared.m
NotRecordingPrefs_INSTALL_PATH = /Library/PreferenceBundles
NotRecordingPrefs_FRAMEWORKS = UIKit
NotRecordingPrefs_PRIVATE_FRAMEWORKS = Preferences
NotRecordingPrefs_EXTRA_FRAMEWORKS = AltList
NotRecordingPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/NotRecordingPrefs.plist$(ECHO_END)
