#!/bin/bash

##
 # @file build/generate_changelog_entry.sh
 # @brief Processes the input file and prints RPM ChangeLog entry
 #
 # (c) 2013-2014 by Mega Limited, Auckland, New Zealand
 #
 # This file is part of the MEGA SDK - Client Access Engine.
 #
 # Applications using the MEGA API must present a valid application key
 # and comply with the the rules set forth in the Terms of Service.
 #
 # The MEGA SDK is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 #
 # @copyright Simplified (2-clause) BSD License.
 #
 # You should have received a copy of the license along with this
 # program.
##

if [ "$#" -ne 1 ]; then
    echo "Please provide input file path"
    exit 1
fi

in_file="$1"
out1=$(awk 'f; /\);/{f=0} /const QString Preferences::CHANGELOG = QString::fromUtf8/{f=1}' $in_file)
# remove ");
out2=$(awk -F'");' '{print $1}' <<< "$out1")
# remove leading and trailing space, tabs and quote marks
out3=$(awk '{ gsub(/^[ \t"]+|[ \t"\n]+$/, ""); print }' <<< "$out2")
# remove trailing "\n"
out4=$(sed "s#\\\\n\$##g" <<< "$out3")
# remove New in this version
out5=$(awk '!/New in this version/' <<< "$out4")
# replace "- " by *
out6=$(sed 's#^- #  * #g' <<< "$out5")

#get version number
new_version=$(awk 'f; /const QString Preferences::VERSION_STRING = QString::fromAscii/' $in_file | \
awk -F'");' '{print $1}' | \
awk -F'\\("' '{print $2}' \
)

# print ChangeLog entry
NOW=$(LANG=en_us_8859_1;date)
echo $NOW - linux@mega.co.nz
echo "- Update to version $new_version:"
echo "$out6"
echo ""
echo "-------------------------------------------------------------------"
