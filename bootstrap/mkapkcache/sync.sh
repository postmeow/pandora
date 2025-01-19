apk update
cd files/x86_64/
for x in $(cat ../../apks); do
apk fetch -R $x
done
rm APKINDEX.tar.gz 2> /dev/null
apk index --rewrite-arch=x86_64 --allow-untrusted $(ls -1 *.apk) > APKINDEX.tar.gz
