PWD=$(shell pwd)
generate-icons:
	flutter pub run flutter_launcher_icons
install:
	flutter pub get
clean:
	flutter clean
build-apk: clean install generate-icons
	flutter build apk --release 
build-bundle: clean install generate-icons
	flutter build appbundle --release 