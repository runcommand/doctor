Feature: Check the value of a given option

  Scenario: Check the value of blog_public
    Given a WP install
    And a blog-private.yml file:
      """
      option-blog-private:
        check: Option_Value
        options:
          option: blog_public
          expected_value: 0
      """
    And a blog-public.yml file:
      """
      option-blog-public:
        check: Option_Value
        options:
          option: blog_public
          expected_value: 1
      """

    When I run `wp option update blog_public 1`
    Then STDOUT should contain:
      """
      Success:
      """

    When I run `wp doctor check --config=blog-private.yml option-blog-private`
    Then STDOUT should be a table containing rows:
      | name                  | status  | message                                    |
      | option-blog-private   | error   | Site is public but expected to be private. |

    When I run `wp doctor check --config=blog-public.yml option-blog-public`
    Then STDOUT should be a table containing rows:
      | name                  | status  | message                                    |
      | option-blog-public    | success | Site is public as expected.                |

    When I run `wp option update blog_public 0`
    Then STDOUT should contain:
      """
      Success:
      """

    When I run `wp doctor check --config=blog-public.yml option-blog-public`
    Then STDOUT should be a table containing rows:
      | name                  | status  | message                                    |
      | option-blog-public    | error   | Site is private but expected to be public. |

    When I run `wp doctor check --config=blog-private.yml option-blog-private`
    Then STDOUT should be a table containing rows:
      | name                  | status  | message                                    |
      | option-blog-private   | success | Site is private as expected.                |

  Scenario: Check the value of admin_email
    Given a WP install
    And a config.yml file:
      """
      option-admin-email:
        check: Option_Value
        options:
          option: admin_email
          expected_value: foo@example.org
      """

    When I run `wp doctor check --config=config.yml option-admin-email`
    Then STDOUT should be a table containing rows:
      | name                  | status  | message                                                                           |
      | option-admin-email    | error   | Option 'admin_email' is 'admin@example.com' but expected to be 'foo@example.org'. |

    When I run `wp option update admin_email foo@example.org`
    Then STDOUT should contain:
      """
      Success:
      """

    When I run `wp doctor check --config=config.yml option-admin-email`
    Then STDOUT should be a table containing rows:
      | name                  | status  | message                                                  |
      | option-admin-email    | success   | Option 'admin_email' is 'foo@example.org' as expected. |