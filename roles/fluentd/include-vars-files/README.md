## fluentd/include-vars-files

This role includes the config.yml file, if it exists and
also includes the `config.yml.d` directory,
where additional var files can be added.

The available variables for this role are:
- `logging_pkg_sysconf_dir:`(default: `/etc/logging`)

  The logging configuration information directory path.

- `logging_config_yml_dir:`(default: `"{{ logging_pkg_sysconf_dir }}/config.yml.d"`)

  The path to the `config.yml.d` directory, where additional var files can be added.

- `logging_config_yml_file:`(default: `"{{ logging_pkg_sysconf_dir }}/config.yml"`)

  The logging config.yml file path.
