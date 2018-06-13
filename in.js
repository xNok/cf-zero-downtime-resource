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

    const appInfo = cf.appInfo(request.params)
    fs.writeFileSync("app.info", JSON.stringify(appInfo, null, 2))

    const result = {
      version: appInfo.metadata,
      metadata: {
        name: appInfo.entity.name,
        buildpack: appInfo.entity.buildpack,
        space: request.source.space,
        organization: request.source.organization,
        memory: appInfo.entity.memory,
        package_updated_at: appInfo.entity.package_updated_at
      }
    }

    concourse.response(result)
  } catch (e) {
    console.error(e)
    process.exit(1)
  }
}

cmd()