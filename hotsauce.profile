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
  $tasks = $tasks + apps_profile_install_tasks($install_state, array('machine name' => 'panopoly', 'default apps' => array('panopoly_demo')));

  // Add subtheme generator to installation workflow
  $tasks['hotsauce_theme_configure_form'] = array(
    'display_name' => t('Configure theme'),
    'type' => 'form',
  );
  $tasks['hotsauce_theme_batch'] = array(
    'display_name' => t('Build theme'),
    'type' => 'batch',
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
 */
function hotsauce_theme_configure_form($form, &$form_state) {
  // Set the page title
  drupal_set_title(t('Configure theme'));

  // Get the form from Kalatheme
  require_once dirname(__FILE__) . '/themes/kalatheme/includes/setup.inc';
  $form = kalatheme_setup_form();

  // Remove some unneeded things, these same things should be verified by
  // Apps server installation
  unset($form['backend_check']);
  unset($form['help_text']);
  $form['enable_theme']['#prefix'] = "<div class='element-invisible'>";
  $form['enable_theme']['#suffix'] = "</div>";

  return $form;
}

/**
 * Wrapper function to the Kalatheme validation magic
 */
function hotsauce_theme_configure_form_validate($form, &$form_state) {
  if (function_exists('kalatheme_setup_form_validate')) {
    kalatheme_setup_form_validate($form, $form_state);
  }
}

/**
 * Wrapper function to the Kalatheme batch magic
 */
function hotsauce_theme_batch() {
  // Get the stuff from Kalatheme
  $form = array();
  $form_state = array();
  foreach ($_POST as $key => $value) {
    $form_state['values'][$key] = $value;
  }
  if (!function_exists('kalatheme_setup_batch')) {
    require_once dirname(__FILE__) . '/themes/kalatheme/includes/setup.inc';
  }
  $batch = kalatheme_setup_batch($form, $form_state);
  // This will be null coming out of kalatheme_setup_batch so we set it here
  // instead
  $batch['file'] = drupal_get_path('profile', 'hotsauce') . '/themes/kalatheme/includes/setup.inc';
  return $batch;
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
