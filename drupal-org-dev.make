; Drush Make file
api = 2
core = 7.x

; Kalatheme

projects[kalatheme][type] = theme
projects[kalatheme][version] = 3.x-dev
projects[kalatheme][download][type] = git
projects[kalatheme][download][branch] = 7.x-3.x

; HotSauce Inheritance !

; Someday maybe we can turn this on to just inherit hot
;projects[hotsauce][type] = profile
;projects[hotsauce][version] = 7.x-1.x-dev
; but, Drupal.org does not support recursive profiles
; and also does not support include[]
; so we need to copy the hotsauce.make file here

; The HotSauce!

projects[hot_core][version] = 1.x-dev
projects[hot_core][subdir] = hotsauce
projects[hot_core][download][type] = git
projects[hot_core][download][branch] = 7.x-1.x

projects[hot_pics][version] = 1.x-dev
projects[hot_pics][subdir] = hotsauce
projects[hot_pics][download][type] = git
projects[hot_pics][download][branch] = 7.x-1.x

projects[hot_theme][version] = 1.x-dev
projects[hot_theme][subdir] = hotsauce
projects[hot_theme][download][type] = git
projects[hot_theme][download][branch] = 7.x-1.x

projects[hot_magic][version] = 1.x-dev
projects[hot_magic][subdir] = hotsauce
projects[hot_magic][download][type] = git
projects[hot_magic][download][branch] = 7.x-1.x

projects[hot_widgets][version] = 1.x-dev
projects[hot_widgets][subdir] = hotsauce
projects[hot_widgets][download][type] = git
projects[hot_widgets][download][branch] = 7.x-1.x

projects[hot_admin][version] = 1.x-dev
projects[hot_admin][subdir] = hotsauce
projects[hot_admin][download][type] = git
projects[hot_admin][download][branch] = 7.x-1.x

projects[hot_users][version] = 1.x-dev
projects[hot_users][subdir] = hotsauce
projects[hot_users][download][type] = git
projects[hot_users][download][branch] = 7.x-1.x

; The HotSauce! Toolset

projects[hot_pages][version] = 1.x-dev
projects[hot_pages][subdir] = hotsauce
projects[hot_pages][download][type] = git
projects[hot_pages][download][branch] = 7.x-1.x

projects[hot_wysiwyg][version] = 1.x-dev
projects[hot_wysiwyg][subdir] = hotsauce
projects[hot_wysiwyg][download][type] = git
projects[hot_wysiwyg][download][branch] = 7.x-1.x

projects[hot_search][version] = 1.x-dev
projects[hot_search][subdir] = hotsauce
projects[hot_search][download][type] = git
projects[hot_search][download][branch] = 7.x-1.x
