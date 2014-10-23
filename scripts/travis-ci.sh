#!/bin/bash

COMMAND=$1
BUILD_TOP=`dirname $TRAVIS_BUILD_DIR`
EXIT_VALUE=0

export PATH="$HOME/.composer/vendor/bin:$PATH"
export DISPLAY=:99.0
export CHROME_SANDBOX=/opt/google/chrome/chrome-sandbox

##
# SCRIPT COMMANDS
##

# system-install
#
# This is meant to setup the server on Travis-CI so that it can run the tests.
#
system_install() {
  # Add the Google Chrome packages.
  header Setting up APT
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
  sudo apt-get update > /dev/null

  # Create a database for our Drupal site.
  mysql -e 'create database drupal;'

  # Install the latest Drush 6.
  header Installing Drush
  composer global require --prefer-source --no-interaction drush/drush:6.*
  drush dl -y drupalorg_drush-7.x-1.x-dev --destination=$HOME/.drush
  drush cc drush

  # Build Codebase
  mkdir profiles
  mv hotsauce profiles/
  mkdir drupal
  mv profiles drupal/

  # Build the current branch.
  header Building Hotsauce from current branch
  cd drupal
  drush make --yes profiles/hotsauce/drupal-org-core.make --prepare-install
  drush make --yes profiles/hotsauce/drupal-org.make --no-core --contrib-destination=profiles/hotsauce
  drush dl diff
  mkdir sites/default/private
  mkdir sites/default/private/files
  mkdir sites/default/private/temp

  # Verify that all the .make files will work on Drupal.org.
  header Verifying .make file
  drush verify-makefile drupal/profiles/hotsauce/drupal-org.make
  find drupal/profiles/hotsauce/modules -name \*.make -print0 | xargs -0 -n1 drush verify-makefile

  # Download an old version to test upgrading from.
  if [[ "$UPGRADE" != none ]]; then
    header Downloading Hotsauce $UPGRADE
    drush dl --yes hotsauce-$UPGRADE
  fi

  # Setup files
  sudo chmod -R 777 drupal/sites/all

  # Setup display for Selenium
  header Starting X
  export DISPLAY=:99.0
  sh -e /etc/init.d/xvfb start
  sleep 5

  # Get Chrome and ChromeDriver
  header Installing Google Chrome
  sudo apt-get install google-chrome-stable
  wget http://chromedriver.storage.googleapis.com/2.9/chromedriver_linux64.zip
  unzip -a chromedriver_linux64.zip

  # Insane hack from jsdevel:
  #   https://github.com/jsdevel/travis-debugging/blob/master/shim.bash
  # This allows chrome-sandbox to work in side of OpenVZ, because I can't
  # figure out how to start chrome with --no-sandbox.
  sudo rm -f $CHROME_SANDBOX
  sudo wget https://googledrive.com/host/0B5VlNZ_Rvdw6NTJoZDBSVy1ZdkE -O $CHROME_SANDBOX
  sudo chown root:root $CHROME_SANDBOX
  sudo chmod 4755 $CHROME_SANDBOX
  sudo md5sum $CHROME_SANDBOX

  # Get Selenium
  header Downloading Selenium
  wget http://selenium-release.storage.googleapis.com/2.41/selenium-server-standalone-2.41.0.jar

  # Disable sendmail
  echo sendmail_path=`which true` >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini
}

# before_tests
#
# Setup Drupal to run the tests.
#
before_tests() {

  # Expand max_nesting_level to prevent error
  phpenv config-add drupal/profiles/hotsauce/travis.php.ini

  # Do the site install (either the current revision or old for the upgrade).
  header Installing Drupal
  if [[ "$UPGRADE" == none ]]; then
    cd drupal
  else
    cd hotsauce-$UPGRADE
  fi
  drush si hotsauce --db-url=mysql://root:@127.0.0.1/drupal --account-name=admin --account-pass=admin --site-mail=admin@example.com --site-name="Hotsauce" --yes
  drush dis -y dblog
  drush vset -y file_private_path "sites/default/private/files"
  drush vset -y file_temporary_path "sites/default/private/temp"

  # Switch to the Hotsauce platform built from Git (if we aren't there already).
  cd ../drupal

  # If we're an upgrade test, run the upgrade process.
  if [[ "$UPGRADE" != none ]]; then
    header Upgrading to latest version
    cp -a ../hotsauce-$UPGRADE/sites/default/* sites/default/ && drush updb --yes
    drush cc all
  fi

  # Run the webserver
  header Starting webserver
  drush runserver --server=builtin 8888 > /dev/null 2>&1 &
  echo $! > /tmp/web-server-pid
  sleep 3

  cd ..

  # Run the selenium server
  header Starting selenium
  java -jar selenium-server-standalone-2.41.0.jar -Dwebdriver.chrome.driver=`pwd`/chromedriver > /dev/null 2>&1 &
  echo $! > /tmp/selenium-server-pid
  sleep 5
}

# before_tests
#
# Run the tests.
#
run_tests() {
  header Running tests
  # here we should execute out selenium tests

  # we execute this just to have a return
  cat /dev/null
}

# after_tests
#
# Clean up after the tests.
#
after_tests() {
  header Cleaning up after tests

  WEB_SERVER_PID=`cat /tmp/webserver-server-pid`
  SELENIUM_SERVER_PID=`cat /tmp/selenium-server-pid`

  # Stop the servers we started
  kill $WEB_SERVER_PID
  kill $SELENIUM_SERVER_PID

  # Build, commit and push to hotsauce-drops-7 only if we have a tag, we are
  # on the main branch, it's not a build for the pull request, and it's done
  # directly from the main project repo and not from a fork
  if [ ! -z $TRAVIS_TAG ] &&
     [ $TRAVIS_BRANCH -eq "7.x-1.x" ] &&
     [ $TRAVIS_PULL_REQUEST -eq "false" ] &&
     [ $TRAVIS_REPO_SLUG -eq "drupalprojects/hotsauce" ]; then

    header Commiting and pushing changes from tag $TAG to kala-travis fork of hotsauce-drops-7
    # Configure GIT
    git config --global user.email "travis@kalamuna.com"
    git config --global user.name "Travis-CI"
    # Clone hotsauce-drops-7 repository and copy changes from hotsauce
    cd $BUILD_TOP
    git clone https://github.com/kala-travis/hotsauce-drops-7.git hotdrops
    rsync -rt --exclude=.git --delete drupal/ hotdrops/
    # Add credentials for kala-travis
    cd hotdrops
    git config --global credential.helper "store --file=.git/credentials"
    echo "https://${GH_TOKEN}:@github.com" > .git/credentials
    # Stage all changes, commit and push
    git add --all
    git commit -m "Changes from hotsauce tag [${TRAVIS_TAG}]"
    git push

  fi

}

##
# UTILITY FUNCTIONS:
##

# Prints a message about the section of the script.
header() {
  set +xv
  echo
  echo "** $@"
  echo
  set -xv
}

# Sets the exit level to error.
set_error() {
  EXIT_VALUE=1
}

# Runs a command and sets an error if it fails.
run_test() {
  if ! $@; then
    set_error
  fi
}

# Runs a command showing all the lines executed
run_command() {
  set -xv
  $@
  set +xv
}

##
# SCRIPT MAIN:
##

# Capture all errors and set our overall exit value.
trap 'set_error' ERR

# We want to always start from the same directory:
cd $BUILD_TOP

case $COMMAND in
  system-install)
    run_command system_install
    ;;

  drupal-install)
    run_command drupal_install
    ;;

  before-tests)
    run_command before_tests
    ;;

  run-tests)
    run_command run_tests
    ;;

  after-tests)
    run_command after_tests
    ;;
esac

exit $EXIT_VALUE
