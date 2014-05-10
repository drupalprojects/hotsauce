; Drush Make file
api = 2
core = 7.x

; Kalatheme

projects[kalatheme][type] = theme
projects[kalatheme][download][type] = git
projects[kalatheme][download][revision] = ee3f1e3
projects[kalatheme][download][branch] = 7.x-3.x
projects[kalatheme][download][url] = http://git.drupal.org/project/kalatheme.git

; HotSauce! Inheritance

; Someday maybe we can turn this on to just inherit hot
;projects[hot][type] = profile
;projects[hot][version] = 7.x-1.0-alpha1
; but, Drupal.org does not support recursive profiles
; and also does not support include[]
; so we need to copy the hot.make file here

; The HotSauce!

projects[hot_core][version] = 1.0-alpha1
projects[hot_core][subdir] = hotsauce

; Other HotSauce! Magix

projects[hot_images][version] = 1.0-alpha1
projects[hot_images][subdir] = hotsauce
projects[hot_theme][version] = 1.0-alpha1
projects[hot_theme][subdir] = hotsauce
projects[hot_magic][version] = 1.0-alpha1
projects[hot_magic][subdir] = hotsauce
projects[hot_widgets][version] = 1.0-alpha1
projects[hot_widgets][subdir] = hotsauce
projects[hot_admin][version] = 1.0-alpha1
projects[hot_admin][subdir] = hotsauce
projects[hot_users][version] = 1.0-alpha1
projects[hot_users][subdir] = hotsauce

; The HotSauce! Toolset

projects[hot_pages][version] = 1.0-alpha1
projects[hot_pages][subdir] = hotsauce
projects[hot_wysiwyg][version] = 1.0-alpha1
projects[hot_wysiwyg][subdir] = hotsauce
projects[hot_search][version] = 1.0-alpha1
projects[hot_search][subdir] = hotsauce
