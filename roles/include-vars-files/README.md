## initial-validations/include-vars-files

This role includes the config.yml file, if it exists and
also includes the `config.yml.d` directory,
where additional var files can be added.

The available variables for this role are:
- `metrics_pkg_sysconf_dir:`(default: `/etc/metrics`)

  The metrics configuration information directory path.

- `metrics_config_yml_dir:`(default: `"{{ metrics_pkg_sysconf_dir }}/config.yml.d"`)

  The path to the `config.yml.d` directory, where additional var files can be added.

- `metrics_config_yml_file:`(default: `"{{ metrics_pkg_sysconf_dir }}/config.yml"`)

  The metrics config.yml file path.
