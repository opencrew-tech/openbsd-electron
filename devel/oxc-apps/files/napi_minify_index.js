import { createRequire } from 'node:module'
const require = createRequire(import.meta.url)

const nativeBinding = require('./minify.node')

const { minify, minifySync, Severity } = nativeBinding
export { minify }
export { minifySync }
export { Severity }
