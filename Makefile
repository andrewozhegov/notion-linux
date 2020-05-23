CURDIR = $(shell pwd)
ARCH ?= x64


.PHONY: check-root
check-root:
ifneq ($(shell id -u), 0)
	echo "Root privileges is required"
	exit 1
endif

.PHONY: clean
clean:
	rm -rf $(CURDIR)/nativefier $(CURDIR)/notion-linux-$(ARCH)

.PHONY: uninstall
uninstall:
	rm -rf /usr/share/notion \
		/usr/share/applications/notion.desktop \
		/usr/bin/notion

nativefier/Dockerfile:
	git clone https://github.com/jiahaog/nativefier

nativefier: nativefier/Dockerfile
	docker build -t local/nativefier nativefier

notion-linux-x64: nativefier
	docker run \
		-v $(CURDIR):/src \
		-v $(CURDIR):/target \
		local/nativefier \
		--inject /src/scrollbar.css \
		--icon /src/icon.png \
		--name notion -p linux -a $(ARCH) https://notion.so/ /target/
	sed -i 's/-nativefier-[a-zA-Z0-9]\+//g' $(CURDIR)/notion-linux-$(ARCH)/resources/app/package.json

install: check-root uninstall notion-linux-$(ARCH)
	cp -r $(CURDIR)/notion-linux-$(ARCH) /usr/share/notion
	cp -u $(CURDIR)/notion.desktop /usr/share/applications/notion.desktop
	ln -sf /usr/share/notion/notion /usr/bin/notion

