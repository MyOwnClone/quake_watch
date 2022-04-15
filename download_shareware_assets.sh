wget https://ia800606.us.archive.org/16/items/Quake_802/zQUAKE_SW-play.zip
unzip zQUAKE_SW-play.zip ID1/PAK0.PAK
mv "ID1/PAK0.PAK" "pak0.pak"
rmdir ID1
mv pak0.pak "qwatch WatchKit Extension/Resources"
rm zQUAKE_SW-play.zip