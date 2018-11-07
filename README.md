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

## resource_types

```
- name: cf-zero-downtime-resource
  type: docker-image
  source:
    repository: emeraldsquad/cf-zero-downtime-resource
    tag: "0.5.2"
```

For a list of available tags, [consult our Docker Hub repo](https://hub.docker.com/r/emeraldsquad/cf-zero-downtime-resource/tags/).

## source

- **api** : _required_ the api endpoint of the Cloud Foundry Cloud Controller
- one of:
  - user credentials
    - **username**: _required_ username to authenticate
    - **password**: _required_ password to authenticate
  - application credentials
    - **client_id**: _required_ client id to authenticate
    - **client_secret**: _required_ client secret to authenticate
- **organization** : _required_ the name of the organization to push to
- **space** : _required_ the name of the space to push to
- **skip_cert_check** : (not implemented yet) _optional_ (`true` or `false`) skip TLS certificate validation (default: `false`)
- **verbose** : (not implemented yet) optional (`true` or `false`) make `cf` CLI more verbose using `CF_TRACE=true` (default: `false`)

## check

Get the deployed app metadata. Only one version is ever returned.

ex:

```
[
  {
    "guid": "5bac9193-ab1a-4f7c-9761-cb082b4068f1",
    "url": "/v2/apps/5bac9193-ab1a-4f7c-9761-cb082b4068f1",
    "created_at": "2018-06-15T18:15:30Z",
    "updated_at": "2018-06-15T18:15:37Z"
  }
]
```

## in

Read in app information into app.json (equivalent to `cf curl /v2/apps/$(cf app NAME --guid)`)

Only the `guid` attribute in the passed in version is taken into account.

## out

Push app to CloudFoundry with zero-downtime. Current app matching **name** will be renamed with the **-venerable** suffix (if an app with the suffix already exists, it will be deleted).

If the push failed, the failed app will be stopped and renamed with the **-failed** suffix. Recent logs will be outputted to make diagnosis easier. The current working app will be renamed back to it's original name.

### params

- **name** : _required_ name of the app to push
- **manifest** : _required_ manifest of the app to push. The _path_ element inside the manifest will be ignored. The manifest must have only **one** application and it must be present under the `applications` key. The manifest can also be specified **inline**, see [bellow for an example](#inline-manifest).
- **path** : _required (except for docker images)_ path for the app bits to deploy. a Glob can be specified, but it must resolve to only one path. If multiple paths match the blob, the deploy will fail (before any interaction with CF)
- **environment_variables** : _optional_ a set of environment variable to set in the manifest file before pushing the app. They will take precedence over any environment variables present.
- **vars** : _optional_ a set of variables to do substitutions with in the manifest file before pushing the app. **NOTE:** Cannot do variable substitution in application names!
- **vars_files** : _optional_ a set of variable files to do substitutions with in the manifest file before pushing the app. **NOTE:** Cannot do variable substitution in application names!
- **docker_username** : _optional_ used to authenticate to private docker registry when pushing docker image.
- **docker_password** : _optional_ used to authenticate to private docker registry when pushing docker image.

For service binding that requires configuration, you can also specify:

- **services**: _optional_ array of additional service bindings that cannot be expressed in the manifest (services that requires a configuration object)
  - **name**: _required_ name of the service to bind to
  - **config**: _required_ configuration object to pass to `bind-service`

Example:

```yaml
jobs:
- name: deploy
  plan:
  - get: my-app-package
  - put: cf-zero-downtime
    params:
      name: my-app
      manifest: my-app-package/manifest.yml
      path: my-app-package/my-app.jar
      services:
      - name: my-service
        config:
          share: my-share
          mount: /home/my-app/data
          uid: "1000"
          gid: "1000"
```

#### Inline Manifest

Instead of providing a path to the manifest file, you can inline the manifest directly in the pipeline.

Example:

```yaml
jobs:
- name: deploy
  plan:
  - get: my-app-dist
  - put: cf-zero-downtime
    params:
      name: my-app
      path: my-app-dist
      manifest:
        applications:
        - name: my-app
          buildpack: nodejs_buildpack
          memory: 64M
          health-check-type: http
          health-check-http-endpoint: /good
```
