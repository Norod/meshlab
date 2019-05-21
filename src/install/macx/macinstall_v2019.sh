#!/bin/bash
# this is a script shell for setting up the application bundle for the mac
# It should be run (not sourced) in the meshlab/src/install/macx dir.
#
# It does all the dirty work of moving all the needed plugins and frameworks into the package and runs the 
# install_tool on them to change the linking path to the local version of qt

if QTDIR="" 
then
QTDIR=/Users/Shared/Qt/5.12.2/clang_64
echo "Warning QTDIR was not set. trying to guess it to" $QTDIR
fi

if ! [ -e $QTDIR ] 
then
echo "Missing QT; QTDIR was wrong:" $QTDIR
fi

# change this according to the shadow build dir.
# is the root of the build e.g. where the meshlab_full.pro it can be something like 
BUILDPATH="../.."

APPNAME="meshlab.app"
echo "Current folder is" `pwd`
echo "Hopefully I should find: " $BUILDPATH/distrib/$APPNAME
echo "Or alternatively in    : " ../distrib/$APPNAME
if ! [ -e $BUILDPATH ] 
then
  BUILDPATH=..
  echo "Hopefully I should find" $BUILDPATH/distrib/$APPNAME
fi

APPFOLDER=$BUILDPATH/distrib/$APPNAME
BUNDLE="MeshLabBundle"


if [ -e $APPFOLDER -a -d $APPFOLDER ]
then
  echo "------------------"
else
  echo "Started in the wrong dir: I have not found the MeshLab.app"
  exit 0
fi

# Start by erasing everything
rm -r -f $BUNDLE

echo "Copying the built app into the bundle"
mkdir $BUNDLE
cp -r $APPFOLDER $BUNDLE
mkdir $BUNDLE/$APPNAME/Contents/PlugIns
# copy the files icons into the app.
cp ../../meshlab/images/meshlab_obj.icns $BUNDLE/$APPNAME/Contents/Resources

for x in $BUILDPATH/distrib/plugins/*.dylib
do
cp ./$x $BUNDLE/meshlab.app/Contents/PlugIns/
done

for x in $BUILDPATH/distrib/plugins/*.xml
do
cp ./$x $BUNDLE/meshlab.app/Contents/PlugIns/
done

for x in $BUNDLE/meshlab.app/Contents/plugins/*.dylib
do
 install_name_tool -change libcommon.1.dylib @executable_path/libcommon.1.dylib $x
done

echo 'Copying samples and other files'

cp $BUILDPATH/distrib/../../LICENSE.txt $BUNDLE
cp $BUILDPATH/distrib/../../docs/readme.txt $BUNDLE

mkdir $BUNDLE/sample
mkdir $BUNDLE/sample/images
mkdir $BUNDLE/sample/normalmap

cp $BUILDPATH/distrib/sample/texturedknot.ply $BUNDLE/sample
cp $BUILDPATH/distrib/sample/texturedknot.obj $BUNDLE/sample
cp $BUILDPATH/distrib/sample/texturedknot.mtl $BUNDLE/sample
cp $BUILDPATH/distrib/sample/TextureDouble_A.png $BUNDLE/sample
cp $BUILDPATH/distrib/sample/Laurana50k.ply $BUNDLE/sample
cp $BUILDPATH/distrib/sample/duck_triangulate.dae $BUNDLE/sample
cp $BUILDPATH/distrib/sample/images/duckCM.jpg $BUNDLE/sample/images
cp $BUILDPATH/distrib/sample/seashell.gts $BUNDLE/sample
cp $BUILDPATH/distrib/sample/chameleon4k.pts $BUNDLE/sample
cp $BUILDPATH/distrib/sample/normalmap/laurana500.* $BUNDLE/sample/normalmap
cp $BUILDPATH/distrib/sample/normalmap/matteonormb.* $BUNDLE/sample/normalmap


mkdir $BUNDLE/$APPNAME/Contents/plugins/U3D_OSX  
cp $BUILDPATH/distrib/plugins/U3D_OSX/IDTFConverter.out  $BUNDLE/$APPNAME/Contents/plugins/U3D_OSX
cp $BUILDPATH/distrib/plugins/U3D_OSX/IDTFConverter.sh  $BUNDLE/$APPNAME/Contents/plugins/U3D_OSX
cp $BUILDPATH/distrib/plugins/U3D_OSX/libIFXCore.so  $BUNDLE/$APPNAME/Contents/plugins/U3D_OSX
mkdir $BUNDLE/$APPNAME/Contents/plugins/U3D_OSX/Plugins
cp $BUILDPATH/distrib/plugins/U3D_OSX/Plugins/libIFXExporting.so  $BUNDLE/$APPNAME/Contents/plugins/U3D_OSX/Plugins

mkdir $BUNDLE/$APPNAME/Contents/textures   
cp $BUILDPATH/distrib/textures/*.png $BUNDLE/$APPNAME/Contents/textures/
mkdir $BUNDLE/$APPNAME/Contents/textures/cubemaps   
cp $BUILDPATH/distrib/textures/cubemaps/uffizi*.jpg $BUNDLE/$APPNAME/Contents/textures/cubemaps
mkdir $BUNDLE/$APPNAME/Contents/textures/litspheres   
cp $BUILDPATH/distrib/textures/litspheres/*.png $BUNDLE/$APPNAME/Contents/textures/litspheres

mkdir $BUNDLE/$APPNAME/Contents/shaders   
cp $BUILDPATH/distrib/shaders/*.gdp $BUILDPATH/distrib/shaders/*.vert $BUILDPATH/distrib/shaders/*.frag $BUILDPATH/distrib/shaders/*.txt  $BUNDLE/$APPNAME/Contents/shaders

#added rendermonkey shaders
mkdir $BUNDLE/$APPNAME/Contents/shaders/shadersrm   
cp $BUILDPATH/distrib/shaders/shadersrm/*.rfx $BUNDLE/$APPNAME/Contents/shaders/shadersrm
#added shadowmapping shaders
cp -r $BUILDPATH/distrib/shaders/decorate_shadow $BUNDLE/$APPNAME/Contents/shaders

echo "Changing the paths of the qt component frameworks using the qt tool macdeployqt"

if [ -e $QTDIR/bin/macdeployqt ]
then
echo
$QTDIR/bin/macdeployqt $BUNDLE/$APPNAME -verbose=2
else
macdeployqt $BUNDLE/$APPNAME -verbose=2
fi

# final step create the dmg using appdmg
# appdmg is installed with 'npm install -g appdmg'",
rm -f $BUNDLE/MeshLab201905.dmg  
appdmg meshlab_dmg.json $BUNDLE/MeshLab201905.dmg
