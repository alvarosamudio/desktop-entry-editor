#!/bin/sh

cd $PWD

# 获取系统语言环境 | Get system locale
LANG=$(locale | grep LANGUAGE | cut -d '=' -f 2 | cut -d '_' -f 1)
if [ "$LANG" != "zh" ] ; then
    LANG="en"
fi

readonly TIP1_zh="开始编译......."
readonly TIP1_en="Compiling..."
readonly TIP2_zh="编译完成"
readonly TIP2_en="Complete"
readonly TIP3_zh="构建软件包..."
readonly TIP3_en="Building deb..."
readonly TIP4_zh="----------包信息----------"
readonly TIP4_en="---------Control---------"
readonly TIP5_zh="构建完成，软件包位于当前目录"
readonly TIP5_en="Complete. See deb in current dir."
readonly TIP6_zh="清除文件..."
readonly TIP6_en="Deleting temp files..."

eval "TIP1=\$TIP1_${LANG}"
eval "TIP2=\$TIP2_${LANG}"
eval "TIP3=\$TIP3_${LANG}"
eval "TIP4=\$TIP4_${LANG}"
eval "TIP5=\$TIP5_${LANG}"
eval "TIP6=\$TIP6_${LANG}"

# 编译 | Compile
echo "$TIP1"

mkdir -p build && cd build
/usr/lib/qt5/bin/qmake ../src/desktop-entry-editor.pro -spec linux-g++ CONFIG+=qtquickcompiler && /usr/bin/make qmake_all
make -j4
cd ..

echo "$TIP2"

# 打包 | Build deb
echo "$TIP3"

mkdir -p ./deb_uos/opt/apps/desktop-entry-editor/files/bin/
mkdir -p ./deb_uos/opt/apps/desktop-entry-editor/files/share/desktop-entry-editor/translations/

cp ./build/desktop-entry-editor ./deb_uos/opt/apps/desktop-entry-editor/files/bin/
cp ./src/translations/desktop-entry-editor_zh_CN.qm ./deb_uos/opt/apps/desktop-entry-editor/files/share/desktop-entry-editor/translations/

find ./deb_uos/opt -type f -print0 | xargs -0 md5sum > ./deb_uos/DEBIAN/md5sums && sed -i "s#./deb_uos/opt#/opt#" ./deb_uos/DEBIAN/md5sums

echo "$TIP4"

cat ./deb_uos/DEBIAN/control

echo "-------------------------"

version=$(cat ./deb_uos/DEBIAN/control | grep "Version" | awk -F ' '  '{print $2}')

fakeroot dpkg -b ./deb_uos ./desktop-entry-editor_"$version"_amd64.deb

echo "$TIP5"

# 清除模板中的文件 | Delete temp files
echo "$TIP6"

rm -rf ./deb_uos/DEBIAN/md5sums
rm -rf ./deb_uos/opt/apps/desktop-entry-editor/files/*

# rm -rf ./build
