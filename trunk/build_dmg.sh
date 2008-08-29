#/bin/sh
if [ ! -e build/Deployment/RandomWeb.saver ]; then echo "RandomWeb.saver not found"; exit 1; fi

if [ -e RandomWeb.dmg ]; then rm RandomWeb.dmg; fi
if [ -e RandomWeb-tmp.dmg ]; then rm RandomWeb-tmp.dmg; fi

hdiutil create -megabytes 4 RandomWeb-tmp.dmg -layout NONE
DISK=`hdid -nomount RandomWeb-tmp.dmg`
echo "Using disk: $DISK"
sudo newfs_hfs -v RandomWeb $DISK
hdiutil eject $DISK
hdid RandomWeb-tmp.dmg
cp -R build/Deployment/RandomWeb.saver /Volumes/RandomWeb
cp Read\ Me.rtf /Volumes/RandomWeb
hdiutil eject $DISK
hdiutil convert -format UDZO RandomWeb-tmp.dmg -o RandomWeb.dmg
rm RandomWeb-tmp.dmg
