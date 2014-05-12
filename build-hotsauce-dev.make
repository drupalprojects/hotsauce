; Drush Make file
;
; Use this file to build a full distribution including Drupal
; core and the "Hot Sauce" distribution using the following command...
;
; drush make build-hotsauce-dev.make <target directory>

api = 2
core = 7.x

; Drupal

includes[] = drupal-org-core.make
includes[] = drupal-org-dev.make

; HotSauce

projects[hotsauce][type] = profile
projects[hotsauce][download][type] = git
projects[hotsauce][download][branch] = 7.x-1.x
