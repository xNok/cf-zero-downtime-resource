const os = require("os")
const child_process = require("child_process")

exports.auth = source => {
  if (process.env.NODE_ENV !== "production") {
    console.log("CF: Non-production: assume we are already logged in")
    return
  }
  const useClientCredentials =
    source.client_id &&
    source.client_id.length > 0 &&
    source.client_secret &&
    source.client_secret.length > 0
  const id = useClientCredentials ? source.client_id : source.username
  const secret = useClientCredentials ? source.client_secret : source.password

  try {
    child_process.execFileSync("cf", ["api", source.api])
    console.log(`CF: API endpoint set to ${source.api}`)
  } catch (e) {
    throw new Error(`CF: Unable to set API endpoint to ${source.api}`)
  }

  try {
    child_process.execFileSync(
      "cf",
      [
        "auth",
        id,
        secret,
        useClientCredentials ? "--client-credentials" : null
      ].filter(n => n)
    )
    console.log(
      `CF: Authenticated with ${id} (client-credentials: ${useClientCredentials})`
    )
  } catch (e) {
    throw new Error(
      `CF: Unable to authenticate with ${id} (client-credentials: ${useClientCredentials})`
    )
  }
}

exports.target = ({ organization, space }) => {
  if (!organization || !space) {
    console.log(
      "CF: Organization and/or space not specified. Using target set locally."
    )
    return
  }
  try {
    child_process.execFileSync("cf", [
      "target",
      "-o",
      organization,
      "-s",
      space
    ])
    console.log(`CF: Targeted ${organization}/${space}`)
  } catch (e) {
    throw new Error(`CF: Unable to target ${organization}/${space}`)
  }
}

exports.appInfo = ({ name }) => {
  try {
    const guid = child_process
      .execFileSync("cf", ["app", "--guid", name])
      .toString()
      .trim()

    const appInfo = child_process
      .execFileSync("cf", ["curl", `/v2/apps/${guid}`])
      .toString()

    return JSON.parse(appInfo)
  } catch (e) {
    throw new Error(`CF: Application '${name}' not found`)
  }
}

exports.appExists = ({ name }) => {
  try {
    child_process.execFileSync("cf", ["app", "--guid", name])
    return true
  } catch (e) {
    return false
  }
}

exports.delete = ({ name }) => {
  child_process.execFileSync("cf", ["delete", name, "-f"])
  console.log(`CF: Deleted ${name}`)
}

exports.rename = ({ from, to, failOnError = true }) => {
  try {
    child_process.execFileSync("cf", ["rename", from, to])
    console.log(`CF: Renamed ${from} to ${to}`)
  } catch (e) {
    if (failOnError) {
      console.error(`CF: Unable to rename ${from} to ${to}`)
    }
  }
}

exports.push = ({ name, path, manifest, docker_password }) => {
  console.log(`CF: Deploying ${name}...`)
  const env = { ...process.env }
  if (docker_password) {
    env["CF_DOCKER_PASSWORD"] = docker_password
  }

  try {
    child_process.execFileSync("cf", [
      "push",
      name,
      "-f",
      manifest,
      "-p",
      path,
      { env }
    ])
    console.log(`CF: Application ${name} successfully deployed!`)
  } catch (e) {
    throw new Error(
      `CF: Unable to deploy ${name}:${os.EOL}${result.stdout}${os.EOL}${
        result.stderr
      }`
    )
  }
}

exports.log = ({ name }) => {
  try {
    const logs = child_process
      .execFileSync("cf", ["logs", "--recent", name])
      .toString()
    return logs
  } catch (e) {
    throw new Error(`CF: Unable to obtain "${name}" logs`)
  }
}

exports.stop = ({ name }) => {
  try {
    child_process.execFileSync("cf", ["stop", name])
    console.log(`CF: Application "${name} stopped.`)
  } catch (e) {
    console.warn(`CF: WARNING Unable to stop application "${name}"`)
  }
}
