CURDIR=$(shell pwd)

nativefier/Dockerfile:
	git clone https://github.com/jiahaog/nativefier

nativefier: nativefier/Dockerfile
	docker build -t local/nativefier nativefier

notion-linux-x64: nativefier
	docker run \
		-v $(CURDIR):/src \
		-v $(CURDIR):/target \
		local/nativefier \
		--icon /src/icon.png \
		--name notion -p linux -a x64 https://notion.so/ /target/
	sed -i 's/-nativefier-[a-zA-Z0-9]\+//g' $(CURDIR)/notion-linux-x64/resources/app/package.json

all: notion-linux-x64
