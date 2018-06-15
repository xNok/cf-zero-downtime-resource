#!/usr/bin/env node

const getStdin = require("get-stdin")
const fs = require("fs")
const cf = require("./cf")
const concourse = require("./concourse")

async function cmd() {
  try {
    concourse.capture()
    concourse.setWorkingDirectory()

    const request = await getStdin().then(JSON.parse)

    cf.auth(request.source)
    cf.target(request.source)

    const appInfo = cf.appInfo({
      name: request.params && request.params.name,
      guid: request.version.guid
    })
    fs.writeFileSync("app.info", JSON.stringify(appInfo, null, 2))

    const result = {
      version: appInfo.metadata,
      metadata: [
        { name: "name", value: appInfo.entity.name },
        { name: "buildpack", value: appInfo.entity.buildpack },
        { name: "space", value: request.source.space },
        { name: "organization", value: request.source.organization },
        { name: "memory", value: `${appInfo.entity.memory}` },
        { name: "package_updated_at", value: appInfo.entity.package_updated_at }
      ]
    }

    concourse.response(result)
  } catch (e) {
    console.error(e)
    process.exit(1)
  }
}

cmd()
