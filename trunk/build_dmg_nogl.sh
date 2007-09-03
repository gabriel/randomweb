#/bin/sh
if [ ! -e build/RandomWebNOGL.saver ]; then echo "RandomWebNOGL.saver not found"; exit 1; fi

if [ -e RandomWebNOGL.dmg ]; then rm RandomWebNOGL.dmg; fi
if [ -e RandomWeb-tmp.dmg ]; then rm RandomWeb-tmp.dmg; fi

hdiutil create -megabytes 4 RandomWeb-tmp.dmg -layout NONE
DISK=`hdid -nomount RandomWeb-tmp.dmg`
echo "Using disk: $DISK"
sudo newfs_hfs -v RandomWeb $DISK
hdiutil eject $DISK
hdid RandomWeb-tmp.dmg
cp -R build/RandomWebNOGL.saver /Volumes/RandomWeb
hdiutil eject $DISK
hdiutil convert -format UDZO RandomWeb-tmp.dmg -o RandomWebNOGL.dmg
rm RandomWeb-tmp.dmg
