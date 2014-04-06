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

; Drupal
includes[] = drupal-org-core.make

; HotSauce
projects[hotsauce][type] = profile
projects[hotsauce][download][type] = git
projects[hotsauce][download][branch] = 7.x-1.1

