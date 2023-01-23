INSTALL_TARGET_PROCESSES = Tweetbot

THEOS_DEVICE_IP = 192.168.178.75
THEOS_PACKAGE_DIR_NAME = debs
TARGET=iphone:clang
ARCHS= arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TweetbotOAuth

TweetbotOAuth_FILES = Tweak.xm
TweetbotOAuth_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
