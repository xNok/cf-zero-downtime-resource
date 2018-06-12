const os = require("os")
const shell = require("shelljs")
const validator = require("validator")

exports.auth = source => {
  if (process.env.NODE_ENV !== "production") {
    console.log("CF: non-production: assume we are already logged in")
    return
  }
  const useClientCredentials =
    !validator.isEmpty(source.client_id) &&
    !validator.isEmpty(source.client_secret)
  const id = useClientCredentials ? source.client_id : source.username
  const secret = useClientCredentials ? source.client_secret : source.password

  const result = shell.exec(
    `cf auth "${id}" "${secret}" ${
      useClientCredentials ? "--client-credentials" : ""
    }`,
    { silent: true }
  )
  if (result.code === 0) {
    console.log(
      `CF: authenticated with ${id} (client-credentials: ${useClientCredentials})`
    )
  } else {
    throw new Error(
      `CF: Unable to authenticate with ${id} (client-credentials: ${useClientCredentials})`
    )
  }
}

exports.target = ({ organization, space }) => {
  if (!organization || !space) {
    console.log(
      "CF: organization and/or space not specified. Using target set locally."
    )
    return
  }
  shell.exec(`cf target -o "${organization}" -s "${space}"`, {
    silent: true
  })
  console.log(`CF: targeted ${organization}/${space}`)
}

exports.appInfo = ({ name }) => {
  const guid = shell.exec(`cf app --guid ${name}`, { silent: true })
  if (guid.code > 0) {
    throw new Error(`CF: application '${name}' not found`)
  }

  const result = shell.exec(`cf curl /v2/apps/${guid.stdout}`, {
    silent: true
  })

  return JSON.parse(result.stdout)
}

exports.appExists = ({ name }) => {
  const guid = shell.exec(`cf app --guid ${name}`, { silent: true })
  return guid.code === 0
}

exports.delete = ({ name }) => {
  shell.exec(`cf delete "${name}" -f`, { silent: true })
  console.log(`CF: deleted ${name}`)
}

exports.rename = ({ from, to, failOnError = true }) => {
  const result = shell.exec(`cf rename "${from}" "${to}"`)
  if (failOnError && result.code > 0) {
    throw new Error(
      `CF: Unable to rename ${from} to ${to} : ${os.EOL}${result.stderr}`
    )
  }
}

exports.push = ({ name, path, manifest, docker_password }) => {
  console.log(`CF: Deploying ${name}...`)
  const env = { ...process.env }
  if (docker_password) {
    env["CF_DOCKER_PASSWORD"] = docker_password
  }

  const result = shell.exec(`cf push "${name}" -f "${manifest}" -p "${path}"`, {
    silent: true,
    env
  })
  if (result.code === 0) {
    console.log(`CF: Application ${name} successfully deployed!`)
  } else {
    throw new Error(
      `CF: Unable to deploy ${name}:${os.EOL}${result.stdout}${os.EOL}${
        result.stderr
      }`
    )
  }
}

exports.log = ({ name }) => {
  const result = shell.exec(`cf logs --recent "${name}"`, { silent: true })
  if (result.code === 0) {
    return result.stdout
  } else {
    throw new Error(
      `CF: Unable to obtain "${name}" logs:${os.EOL}${result.stderr}`
    )
  }
}

exports.stop = ({ name }) => {
  const result = shell.exec(`cf stop "${name}"`)
  if (result.code === 0) {
    console.log(`CF: Application "${name} stopped.`)
  } else {
    console.warn(`CF: WARNING Unable to stop application "${name}"`)
  }
}
