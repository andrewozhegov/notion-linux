CURDIR=$(shell pwd)

.PHONY: check-root
check-root:
ifneq ($(shell id -u), 0)
	echo "Root privileges is required"
	exit 1
endif

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
		--name notion -p linux -a x64 https://notion.so/ /target/
	sed -i 's/-nativefier-[a-zA-Z0-9]\+//g' $(CURDIR)/notion-linux-x64/resources/app/package.json

install: check-root notion-linux-x64
	cp -r $(CURDIR)/notion-linux-x64 /usr/share/notion
	cp $(CURDIR)/notion.desktop /usr/share/applications/notion.desktop
	ln -s /usr/share/notion/notion /usr/bin/notion
