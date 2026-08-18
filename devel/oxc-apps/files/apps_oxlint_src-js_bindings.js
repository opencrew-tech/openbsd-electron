import { createRequire } from 'node:module'
const require = createRequire(import.meta.url)

const nativeBinding = require('./oxlint.node')

const { Severity, applyFixes, getBufferOffset, lint, parseRawSync, rawTransferSupported } = nativeBinding
export { Severity }
export { applyFixes }
export { getBufferOffset }
export { lint }
export { parseRawSync }
export { rawTransferSupported }
