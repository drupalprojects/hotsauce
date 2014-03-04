; Drush Make file
;
; Use this file to build a full distribution including Drupal core and the
; "Hot Sauce" distribution using the following command...
;
; drush --no-patch-txt make build-hotsauce.make <target directory>

api = 2
core = 7.x

; Include the definition for how to build Drupal core directly, including
; patches.

includes[] = drupal-org-core.make

; Download the Hot Sauce and recursively build all
; of its dependencies.

projects[hotsauce][type] = profile
; The following two lines allow for pulling the distribution from the drupal
; git repository;
projects[hotsauce][download][type] = git
projects[hotsauce][download][branch] = 7.x-1.1
; You can optionally build from a local directory using the make_local drush
; module found at http://drupal.org/project/make_local.
;projects[hotsauce][download][type] = local
;projects[hotsauce][download][source] = /var/www/zenzen/profiles/hotsauce
