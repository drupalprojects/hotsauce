<?php
/**
 * @file hotsauce.profile
 */

/**
 * Implements hook_install_tasks().
 *
 * Note, these tasks run after the "Configure site" step (where the admin
 * password is set).
 */
function hotsauce_install_tasks($install_state) {
  // Add custom tasks to the tasks array.
  $tasks = array();

  // Add our custom CSS file for the installation process
  drupal_add_css(drupal_get_path('profile', 'hotsauce') . '/hotsauce.css');

  // @todo: Switch to Kalamuna App server
  require_once(drupal_get_path('module', 'apps') . '/apps.profile.inc');
  $tasks = $tasks + apps_profile_install_tasks($install_state, array('machine name' => 'hotapps', 'default apps' => array()));

  // Add subtheme generator to installation workflow
  $tasks['hotsauce_theme_configure_form'] = array(
    'display_name' => t('Configure theme'),
    'type' => 'form',
  );

  return $tasks;
}

/**
 * Implements hook_install_tasks_alter()
 */
function hotsauce_install_tasks_alter(&$tasks, $install_state) {
  // Magically go one level deeper in solving years of dependency problems.
  require_once(drupal_get_path('module', 'panopoly_core') . '/panopoly_core.profile.inc');
  $tasks['install_load_profile']['function'] = 'panopoly_core_install_load_profile';
}

/**
 * Form to configure the Kalatheme
 * @todo we should move this stuff into kalatheme so it can be used in other
 * install profiles
 */
function hotsauce_theme_configure_form($form, &$form_state) {
  // Set the page title
  drupal_set_title(t('Configure theme'));

  // Get the form from Kalatheme
  require_once dirname(__FILE__) . '/themes/kalatheme/includes/config.inc';

  // Kalatheme settings
  $form = array_merge($form, kalatheme_bootstrap_library_form());
  $form['bootstrap']['bootstrap_library']['#default_value'] = theme_get_setting('bootstrap_library');
  $form['bootstrap']['fontawesome']['#default_value'] = theme_get_setting('fontawesome');
  $form['bootstrap']['bootstrap_upload']['#default_value'] = theme_get_setting('bootstrap_upload');
  // Subtheme settings
  // @todo: subthemes don't work yet here.
  //$form = array_merge($form, kalatheme_subtheme_form());
  // Make sure the callback function and other fun things are actually loaded
  $form = system_settings_form($form);
  // We don't want to call system_settings_form_submit(), so change #submit.
  array_pop($form['#submit']);
  $form['#submit'][] = 'system_theme_settings_submit';

  // Prepasre the form so it can handle subtheme things
  $form = kalatheme_prepare_config_form($form);
  // Kalatheme normally assumes that it is enabled and set default
  // In the installer this is not true so we should set default and enable
  // if appropriate
  array_unshift($form['#submit'], 'hotsauce_enable_theme');

  $form_state['build_info']['files'][] = drupal_get_path('theme', 'kalatheme') . '/includes/config.inc';
  $form_state['build_info']['files'][] = drupal_get_path('theme', 'kalatheme') . '/kalatheme.updater.inc';

  return $form;
}

/**
 * Wrapper function to the Kalatheme validation magic
 */
function hotsauce_theme_configure_form_validate($form, &$form_state) {
  if (function_exists('kalatheme_custom_bootstrap_library_validate')) {
    kalatheme_custom_bootstrap_library_validate($form, $form_state);
  }
}

/**
 * Wrapper function to the Kalatheme validation magic
 */
function hotsauce_enable_theme($form, &$form_state) {
  // Generate subtheme and build its settings var
  // @todo we should move this stuff into kalatheme so it can be used in other
  // install profiles
  //
  // @todo: support for subtheme generation.
  //if (isset($form_state['values']['build_subtheme']) && !$form_state['values']['build_subtheme']) {
    // Set basic settings
    $theme_settings['bootstrap_library'] = $form_state['values']['bootstrap_library'];
    $theme_settings['fontawesome'] = $form_state['values']['fontawesome'];
    // We do this to trick kalatheme_custom_subtheme_vars
    $theme_settings['subtheme_name'] = 'kalatheme';
    kalatheme_custom_subtheme_vars($theme_settings);
    // Enable and redirect if required
    // Rebuild theme registry stuff
    system_rebuild_theme_data();
    drupal_theme_rebuild();
    // Enable new theme
    theme_enable(array('kalatheme'));
    variable_set('theme_default', 'kalatheme');
    // We need to do the big dump
    // @todo: should figure out the actual caches we need to clear
    drupal_flush_all_caches();
 // }
}

/**
 * Implements hook_form_FORM_ID_alter()
 */
function hotsauce_form_install_configure_form_alter(&$form, $form_state) {

  // Hide some messages from various modules that are just too chatty.
  drupal_get_messages('status');
  drupal_get_messages('warning');

  // Set reasonable defaults for site configuration form
  $form['site_information']['site_name']['#default_value'] = 'HotSauce!';
  $form['admin_account']['account']['name']['#default_value'] = 'admin';

  // Define a default email address if we can guess a valid one
  if (valid_email_address('admin@' . $_SERVER['HTTP_HOST'])) {
    $form['site_information']['site_mail']['#default_value'] = 'admin@' . $_SERVER['HTTP_HOST'];
    $form['admin_account']['account']['mail']['#default_value'] = 'admin@' . $_SERVER['HTTP_HOST'];
  }

  // Set the location to be in San Francisco CA
  $form['server_settings']['site_default_country']['#default_value'] = 'US';
  $form['server_settings']['date_default_timezone']['#default_value'] = 'America/Los_Angeles';
  $form['server_settings']['date_default_timezone']['#attributes']['class'] = array();
}
