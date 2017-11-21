LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := clsockets_static

LOCAL_MODULE_FILENAME := libclsockets

LOCAL_SRC_FILES := \
ActiveSocket.cpp \
PassiveSocket.cpp \
SimpleSocket.cpp \


LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH) 

LOCAL_C_INCLUDES := $(LOCAL_PATH) 

LOCAL_CFLAGS := -D_LINUX -DANDROID
LOCAL_EXPORT_CFLAGS := -D_LINUX

include $(BUILD_STATIC_LIBRARY)

