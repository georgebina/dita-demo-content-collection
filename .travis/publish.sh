#!/bin/bash

echo "Publish $TRAVIS_BRANCH !"

REPONAME=`basename $PWD`
echo "REPONAME $REPONAME"

PARENTDIR=`dirname $PWD`
echo "PARENTDIR $PARENTDIR"

USERNAME=`basename $PARENTDIR`
echo "USERNAME $USERNAME"

java -version

echo "====================================="
echo "download DITA-OT"
echo "====================================="
wget https://github.com/dita-ot/dita-ot/releases/download/2.5.2/dita-ot-2.5.2.zip >> download.log 2>>download.log
echo "..."
tail -n 2 download.log

echo "====================================="
echo "extract DITA-OT"
echo "====================================="
unzip dita-ot-2.5.2.zip >> extract.log 2>>extract.log
head -n 10 extract.log
echo "..."

echo "====================================="
echo "download WebHelp plugin"
echo "====================================="

wget https://www.oxygenxml.com/InstData/WebHelp/oxygen-webhelp-dot-2.x.zip  >> download.log 2>>download.log
echo "..."
tail -n 2 download.log

echo "====================================="
echo "extract WebHelp to DITA-OT"
echo "====================================="
unzip oxygen-webhelp-dot-2.x.zip >> extract.log 2>>extract.log
head -n 10 extract.log
echo "..."
cp -R com.oxygenxml.* dita-ot-2.5.2/plugins/

# echo $WEBHELP_LICENSE | tr " " "\n" | head -3 | tr "\n" " " > licensekey.txt
# echo "" >> licensekey.txt
# echo $WEBHELP_LICENSE | tr " " "\n" | tail -8  >> licensekey.txt

echo $WEBHELP_LICENSE | tr " " "\n" > licensekey.txt

echo "****"
cat licensekey.txt | head -8
echo "****"

cp licensekey.txt dita-ot-2.5.2/plugins/com.oxygenxml.webhelp.responsive/licensekey.txt


echo "====================================="
echo "Add Edit Link to DITA-OT"
echo "====================================="

# Add the editlink plugin
git clone https://github.com/oxygenxml/dita-reviewer-links plugins/
cp -R plugins/com.oxygenxml.editlink dita-ot-2.5.2/plugins/

echo "====================================="
echo "integrate plugins"
echo "====================================="
cd dita-ot-2.5.2/
bin/ant -f integrator.xml 
cd ..


echo "====================================="
echo "download Saxon9"
echo "====================================="
wget http://sourceforge.net/projects/saxon/files/Saxon-HE/9.9/SaxonHE9-9-0-1J.zip >> download.log 2>>download.log
echo "..."
tail -n 2 download.log

echo "====================================="
echo "extract Saxon9"
echo "====================================="
unzip SaxonHE9-9-0-1J.zip -d saxon9/ >> extract.log 2>>extract.log
head -n 10 extract.log
echo "..."


echo "====================================="
echo "Publish the content as WebHelp"
echo "====================================="


# Send some parameters to the "editlink" plugin as system properties
export ANT_OPTS="$ANT_OPTS -Deditlink.remote.ditamap.url=github://getFileContent/$USERNAME/$REPONAME/$TRAVIS_BRANCH/Thunderbird/User_Guide.ditamap"
# Send parameters for the Webhelp styling.
export ANT_OPTS="$ANT_OPTS -Dwebhelp.fragment.welcome='$WELCOME'"

#export ANT_OPTS="$ANT_OPTS -Dwebhelp.responsive.template.name=bootstrap" 
#export ANT_OPTS="$ANT_OPTS -Dwebhelp.responsive.variant.name=tiles"
export ANT_OPTS="$ANT_OPTS -Dwebhelp.publishing.template=dita-ot-2.5.2/plugins/com.oxygenxml.webhelp.responsive/templates/$TEMPLATE/$TEMPLATE-$VARIANT.opt"


OUT=out/$TRAVIS_BRANCH
FOLDER=/$TRAVIS_BRANCH

dita-ot-2.5.2/bin/dita -i Thunderbird/User_Guide.ditamap -f webhelp-responsive -o $OUT
echo "====================================="
echo "https://$USERNAME.github.io/$REPONAME$FOLDER/index.html"
echo "====================================="
cat $OUT/index.html
