CXXFLAGS ?= -O2
CXXFLAGS += -shared -fPIC -std=c++2b -Wno-c++11-narrowing
ifeq ($(CXX),g++)
    CXXFLAGS += --no-gnu-unique
endif
INCLUDES = $(shell pkg-config --cflags pixman-1 libdrm hyprland libinput libudev wayland-server xkbcommon)

all: yui-snap.so

yui-snap.so: main.cpp
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(INCLUDES) $^ -o $@

clean:
	rm -f yui-snap.so

.PHONY: all clean
