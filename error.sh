#!/bin/sh -e

DIR=$PWD

echo "\n\n\n"

echo "-----------------------------"
echo "Script Error: please cut and paste the following into to GitHub issue "
echo "**********************************************************"
echo "Error: [${ERROR_MSG}]"

if [ -f "${DIR}/.git/config" ] ; then
	gitrepo=$(cat "${DIR}/.git/config" | grep url | awk '{print $3}')
	gitwhatchanged=$(git whatchanged -1)
	echo "git repo: [${gitrepo}]"
	echo "-----------------------------"
	echo "${gitwhatchanged}"
	echo "-----------------------------"
else
	if [ "${BRANCH}" ] ; then
		echo "nongit: [${BRANCH}]"
	else
		echo "nongit: [master]"
	fi
fi


echo "uname -m"
uname -m
if [ "$(which lsb_release)" ] ; then
	echo "lsb_release -a"
	lsb_release -a
fi
echo "**********************************************************"

