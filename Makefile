# PREFIX is environment variable, but if it is not set, then set default value
ifeq ($(PREFIX),)
    PREFIX := /
endif

ifeq ($(VERSION),)
	VERSION := $(shell git describe --long --tags | sed 's/\([^-]*-g\)/r\1/;s/-/./g')
endif

.PHONY: install

install:
	mkdir -p "${PREFIX}/usr/bin"
	install -m 755 "frzr" "${PREFIX}/usr/bin"
	install -m 755 "__frzr" "${PREFIX}/usr/bin"
	install -m 755 "frzr-deploy" "${PREFIX}/usr/bin"
	install -m 755 "__frzr-deploy" "${PREFIX}/usr/bin"
	install -m 755 "frzr-unlock" "${PREFIX}/usr/bin"
	install -m 755 "__frzr-unlock" "${PREFIX}/usr/bin"
	install -m 755 "frzr-bootloader" "${PREFIX}/usr/bin"
	install -m 755 "__frzr-bootloader" "${PREFIX}/usr/bin"
	install -m 755 "frzr-kernel" "${PREFIX}/usr/bin"
	install -m 755 "__frzr-kernel" "${PREFIX}/usr/bin"
	install -m 755 "frzr-version" "${PREFIX}/usr/bin"
	install -m 755 "__frzr-version" "${PREFIX}/usr/bin"
	install -m 755 "frzr-bootstrap" "${PREFIX}/usr/bin"
	install -m 755 "__frzr-bootstrap" "${PREFIX}/usr/bin"
	install -m 755 "__frzr-envars" "${PREFIX}/usr/bin"
	install -m 755 "frzr-source" "${PREFIX}/usr/bin"
	install -m 755 "frzr-extras" "${PREFIX}/usr/bin"
	install -m 755 "frzr-release" "${PREFIX}/usr/bin"
	sed -i "s|1.0.0|${VERSION}|g" "${PREFIX}/usr/bin/__frzr-version"
