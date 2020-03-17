#!/usr/bin/env node
// return the versions array with  current app
// if app never deployed, return empty array

const getStdin = require("get-stdin")
const cf = require("./cf")
const concourse = require("./concourse")

async function cmd() {
  try {
    concourse.capture()
    const request = await getStdin().then(JSON.parse)

    cf.auth(request.source)
    cf.target(request.source)

    try {
      const appInfo = cf.appInfo({ name: request.source.app_name })
      concourse.response([appInfo.metadata])
    } catch (e) {
      concourse.response([])
    }
  } catch (e) {
    console.error(e)
    process.exit(1)
  }
}

cmd()
