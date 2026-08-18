import { createRequire } from 'node:module'
const require = createRequire(import.meta.url)

const nativeBinding = require("./oxfmt.node")

const { Severity, format, jsTextToDoc, runCli } = nativeBinding
export { Severity }
export { format }
export { jsTextToDoc }
export { runCli }