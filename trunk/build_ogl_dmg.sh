#/bin/sh

NAME="RandomWebOGL"

if [ ! -e build/$NAME.saver ]; then echo "$NAME.saver not found"; exit 1; fi

if [ -e $NAME.dmg ]; then rm $NAME.dmg; fi
if [ -e $NAME-tmp.dmg ]; then rm $NAME-tmp.dmg; fi

hdiutil create -megabytes 1 $NAME-tmp.dmg -layout NONE
DISK=`hdid -nomount $NAME-tmp.dmg`
echo "Using disk: $DISK"
sudo newfs_hfs -v $NAME $DISK
hdiutil eject $DISK
hdid $NAME-tmp.dmg
cp -R build/$NAME.saver /Volumes/$NAME
hdiutil eject $DISK
hdiutil convert -format UDZO $NAME-tmp.dmg -o $NAME.dmg
rm $NAME-tmp.dmg
