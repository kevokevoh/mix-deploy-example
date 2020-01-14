use Mix.Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.

config :mix_deploy_example, MixDeployExampleWeb.Endpoint,
  http: [:inet6, port: 4000],
  # url: [host: {:system, "HOST"}, port: 80],
  # static_url: [host: System.get_env("ASSETS_HOST"), port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :mix_deploy_example, MixDeployExampleWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [
#         :inet6,
#         port: 443,
#         cipher_suite: :strong,
#         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
#       ]
#
# The `cipher_suite` is set to `:strong` to support only the
# latest and more secure SSL ciphers. This means old browsers
# and clients may not be supported. You can set it to
# `:compatible` for wider support.
#
# `:keyfile` and `:certfile` expect an absolute path to the key
# and cert in disk or a relative path inside priv, for example
# "priv/ssl/server.key". For all supported SSL configuration
# options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
#
# We also recommend setting `force_ssl` in your endpoint, ensuring
# no data is ever sent via http, always redirecting to https:
#
#     config :mix_deploy_example, MixDeployExampleWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases (distillery)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:

config :phoenix, :serve_endpoints, true

# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :mix_deploy_example, MixDeployExampleWeb.Endpoint, server: true
#
# Note you can't rely on `System.get_env/1` when using releases.
# See the releases documentation accordingly.

config :mix_systemd,
  # release_system: :distillery,
  release_name: Mix.env(),
  dirs: [
    # Create /etc/mix-deploy-example
    :configuration,
    # Create /run/mix-deploy-example
    # :runtime,
  ],
  # Don't clear runtime dir between restarts, useful for debugging
  # runtime_directory_preserve: "yes",
  env_files: [
    # Load environment vars from /srv/mix-deploy-example/etc/environment
    ["-", :deploy_dir, "/etc/environment"],
    # Load environment vars from /etc/mix-deploy-example/environment
    ["-", :configuration_dir, "/environment"],
  ],
  # env_vars: [
  #   # Tell release scripts to use runtime directory for temp files
  #   # Mix
  #   ["RELEASE_TMP=", :runtime_dir],
  #   # Distillery
  #   # ["RELEASE_MUTABLE_DIR=", :runtime_dir],
  #   # "REPLACE_OS_VARS=true",
  # ],
  app_user: "app",
  app_group: "app"

config :mix_deploy,
  # release_system: :distillery,
  release_name: Mix.env(),
  templates: [
    # Systemd wrappers
    "start",
    "stop",
    "restart",
    "enable",

    # System setup
    "create-users",
    "create-dirs",

    # Local deploy
    "init-local",
    "copy-files",
    "release",
    "rollback",

    # CodeDeploy
    # "clean-target",
    # "extract-release",
    # "set-perms",

    # CodeBuild
    # "stage-files",
    # "sync-assets-s3",

    # Release commands
    "set-env",
    "remote-console",
    "migrate",

    # Runtime environment
    # "sync-config-s3",
    # "runtime-environment-file",
    # "runtime-environment-wrap",
    # "set-cookie-ssm",
  ],
  # This should match mix_systemd
  env_files: [
    ["-", :deploy_dir, "/etc/environment"],
    ["-", :configuration_dir, "/environment"],
  ],
  # This should match mix_systemd
  # env_vars: [
  #   # Tell release scripts to use runtime directory for temp files
  #   # Mix
  #   ["RELEASE_TMP=", :runtime_dir],
  #   # Distillery
  #   # ["RELEASE_MUTABLE_DIR=", :runtime_dir],
  #   # "REPLACE_OS_VARS=true",
  # ],
  # Have deploy-copy-files copy config/environment to /etc/mix-deploy-example
  copy_files: [
    %{
      src: "config/environment",
      dst: :configuration_dir,
      user: "$DEPLOY_USER",
      group: "$APP_GROUP",
      mode: "640"
    },
  ],
  app_user: "app",
  app_group: "app"

# Finally import the config/prod.secret.exs which should be versioned
# separately.
# import_config "prod.secret.exs"
