; Drush Make file
api = 2
core = 7.x

; Kalatheme

projects[kalatheme][type] = theme
projects[kalatheme][download][type] = git
projects[kalatheme][download][revision] = 86c1705
projects[kalatheme][download][branch] = 7.x-3.x
projects[kalatheme][download][url] = http://git.drupal.org/project/kalatheme.git

; Hotsauce

; HotSauce Core Contrib Modules
; For release build, we should grab the most stable module versions
; that we know work with HotSauce and its apps.

projects[better_formats][subdir] = "contrib"
projects[diff][subdir] = "contrib"
projects[pathologic][subdir] = contrib
projects[transliteration][subdir] = contrib
projects[imagecache_token][subdir] = contrib
projects[imagefield_tokens][subdir] = contrib
projects[filefield_paths][subdir] = contrib
projects[entitycache][subdir] = contrib
projects[views_cache_bully][subdir] = contrib
projects[picture][subdir] = contrib
projects[speedy][subdir] = contrib
projects[icon][version] = 1.x-dev
projects[icon][subdir] = contrib

; Panopoly

; Someday maybe we can turn this on to just inherit Panopoly
;projects[panopoly][type] = profile
;projects[panopoly][version] = 7.x-1.2
; but, Drupal.org does not support recursive profiles
; and also does not support include[]
; so we need to copy the panopoly.make file here

; The Panopoly Foundation

projects[panopoly_core][version] = 1.8
projects[panopoly_core][subdir] = panopoly

projects[panopoly_images][version] = 1.8
projects[panopoly_images][subdir] = panopoly

projects[panopoly_theme][version] = 1.8
projects[panopoly_theme][subdir] = panopoly

projects[panopoly_magic][version] = 1.8
projects[panopoly_magic][subdir] = panopoly

projects[panopoly_widgets][version] = 1.8
projects[panopoly_widgets][subdir] = panopoly

projects[panopoly_admin][version] = 1.8
projects[panopoly_admin][subdir] = panopoly

projects[panopoly_users][version] = 1.8
projects[panopoly_users][subdir] = panopoly

; The Panopoly Toolset

projects[panopoly_pages][version] = 1.8
projects[panopoly_pages][subdir] = panopoly

projects[panopoly_wysiwyg][version] = 1.8
projects[panopoly_wysiwyg][subdir] = panopoly

projects[panopoly_search][version] = 1.8
projects[panopoly_search][subdir] = panopoly
