Feature: Check the status of a plugin

  Scenario: Verify check description
    Given a WP install
    And a config.yml file:
      """
      plugin-akismet-active:
        class: runcommand\Doctor\Checks\Plugin_Status
        options:
          name: akismet
          status: active
      """

    When I run `wp doctor list --fields=name,description --config=config.yml`
    Then STDOUT should be a table containing rows:
      | name                       | description                                                                    |
      | plugin-akismet-active      | Errors if plugin 'akismet' isn't in the expected state 'active'.               |

  Scenario: Basic usage
    Given a WP install
    And a config.yml file:
      """
      plugin-akismet-active:
        class: runcommand\Doctor\Checks\Plugin_Status
        options:
          name: akismet
          status: active
      plugin-hello-uninstalled:
        class: runcommand\Doctor\Checks\Plugin_Status
        options:
          name: hello
          status: uninstalled
      """

    When I run `wp doctor check --all --config=config.yml --fields=name,status,message,recommendation_message,recommendation_command`
    Then STDOUT should be a table containing rows:
      | name                  | status  | message                                                      | recommendation_message | recommendation_command |
      | plugin-akismet-active | error   | Plugin 'akismet' is 'inactive' but expected to be 'active'.  | Activate the akismet plugin. | wp plugin activate akismet |
      | plugin-hello-uninstalled | error   | Plugin 'hello' is 'inactive' but expected to be 'uninstalled'. | Uninstall the hello plugin. | wp plugin delete hello |

    When I run `wp plugin activate akismet`
    Then STDOUT should not be empty

    When I run `wp doctor check --all --config=config.yml`
    Then STDOUT should be a table containing rows:
      | name                  | status  | message                                                      |
      | plugin-akismet-active | success   | Plugin 'akismet' is 'active' as expected.                  |
      | plugin-hello-uninstalled | error   | Plugin 'hello' is 'inactive' but expected to be 'uninstalled'. |

    When I run `wp plugin delete hello`
    Then STDOUT should not be empty

    When I run `wp doctor check --all --config=config.yml`
    Then STDOUT should be a table containing rows:
      | name                     | status  | message                                                |
      | plugin-akismet-active    | success   | Plugin 'akismet' is 'active' as expected.            |
      | plugin-hello-uninstalled | success   | Plugin 'hello' is 'uninstalled' as expected.         |

  Scenario: Invalid status registered
    Given a WP install
    And a config.yml file:
      """
      plugin-akismet-active-network:
        class: runcommand\Doctor\Checks\Plugin_Status
        options:
          name: akismet
          status: active-network
      """

    When I try `wp doctor check plugin-akismet-active-network --config=config.yml`
    Then STDERR should be:
      """
      Error: Invalid plugin_status. Should be one of: uninstalled, installed, active.
      """
