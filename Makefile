CURDIR := $(shell pwd)
ARCH ?= x64
VERSION ?= 0.2
REPO_NAME := nativefier/nativefier
CONTAINER_NAME := notion_builder

.PHONY: check-root
check-root:
ifneq ($(shell id -u), 0)
	echo "Root privileges is required"
	exit 1
endif

.PHONY: clean
clean:
	rm -rf $(CURDIR)/nativefier $(CURDIR)/notion-linux-$(ARCH)
	docker rmi -f $(REPO_NAME)
	docker rm $(CONTAINER_NAME)

.PHONY: uninstall
uninstall:
	rm -rf /usr/share/notion \
		/usr/share/applications/notion.desktop \
		/usr/bin/notion

notion-linux-$(ARCH):
	docker run \
		-v $(CURDIR):/src \
		-v $(CURDIR):/target \
		--name $(CONTAINER_NAME) \
		$(REPO_NAME) \
		--inject /src/scrollbar.css \
		--icon /src/icon.png \
		--name notion -p linux -a $(ARCH) https://notion.so/ /target/
	sed -i \
		-e 's/-nativefier-[a-zA-Z0-9]\+//g' \
        -e 's/"version":"1.0.0"/"version":"$(VERSION)"/g' \
		$(CURDIR)/notion-linux-$(ARCH)/resources/app/package.json

notion-linux-$(ARCH).tar.gz: notion-linux-$(ARCH)
	tar -zcf notion_$(VERSION).tar.gz notion-linux-$(ARCH)

install: check-root uninstall notion-linux-$(ARCH)
	cp -r $(CURDIR)/notion-linux-$(ARCH) /usr/share/notion
	cp -u $(CURDIR)/notion.desktop /usr/share/applications/notion.desktop
	ln -sf /usr/share/notion/notion /usr/bin/notion

