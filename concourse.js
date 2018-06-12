var stdout = null

exports.capture = () => {
  stdout = process.stdout.write.bind(process.stdout)

  process.stdout.write = process.stderr.write.bind(process.stderr)
}

exports.setWorkingDirectory = () => {
  const wd = process.argv.length > 2 ? process.argv[2] : process.cwd()
  process.chdir(wd)
}

exports.response = result => {
  result =
    typeof result === "object" ? JSON.stringify(result || {}, null, 2) : result

  if (!stdout) {
    console.error(
      "WARNING: You should call concourse.capture() before everything else in you concourse script!"
    )
  }

  ;(stdout || process.stdout.write.bind(process.stdout))(result)
}
