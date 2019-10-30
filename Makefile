INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

export TARGET = iphone:clang:11.2:8.0
export ARCHS = arm64e arm64 armv7

TWEAK_NAME = NotRecording
NotRecording_FILES = Tweak.xm
NotRecording_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
