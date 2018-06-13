Deploy application to Cloud Foundry with zero downtime.

Features:
- CF manifest is the truth
- UP application name stays the same
- Play well with CF services like SSO, Eureka, ...
- Use CF built-in health check (as specified in the manifest)
- Ability to bind services that requires binding configuration (not supported in manifest.yml)
- Can be used as input

## Health check
The health check of the newly deployed application is based on the manifest `health-check-type`.

It is strongly recommended to user `health-check-type: http` and `health-check-http-endpoint` to specify a health check route if your application uses http.

## source
- **api** : *required* the api endpoint of the Cloud Foundry Cloud Controller
- one of:
  - user credentials
    - **username**: *required* username to authenticate
    - **password**: *required* password to authenticate
  - application credentials
    - **client_id**: *required* client id to authenticate
    - **client_secret**: *required* client secret to authenticate
- **organization** : *required* the name of the organization to push to
- **space** : *required* the name of the space to push to
- **skip_cert_check** : *optional* (`true` or `false`) skip TLS certificate validation (default: `false`)
- **verbose** : optional (`true` or `false`) make `cf` CLI more verbose using `CF_TRACE=true` (default: `false`)

## in
Read in app information into app.json (equivalent to `cf curl /v2/apps/$(cf app NAME --guid)`)

version is not taken into account as it is not meaningful in the context of an app running in CF.

params:
- name: The name of the app

## out
Push app to CloudFoundry with zero-downtime. Current app matching **name** will be renamed with the **-venerable** suffix (if an app with the suffix already exists, it will be deleted).
- **name** : *required* name of the app to push
- **manifest** : *required* manifest of the app to push. The *path* element inside the manifest will be ignored. The manifest must have only **one** application and it must be present under the `applications` key.
- **path** : *required (except for docker images)* path for the app bits to deploy. a Glob can be specified, but it must resolve to only one path. If multiple paths match the blob, the deploy will fail (before any interaction with CF)
- **environment_variables** : *optional* a set of environment variable to set in the manifest file before pushing the app. They will take precedence over any environment variables present.
- **docker_username** : *optional* used to authenticate to private docker registry when pushing docker image.
- **docker_password** : *optional* used to authenticate to private docker registry when pushing docker image.
