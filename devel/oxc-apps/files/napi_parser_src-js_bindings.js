import { createRequire } from 'node:module'
const require = createRequire(import.meta.url)

const nativeBinding = require('./parser.node')

const { Severity, ParseResult, ExportExportNameKind, ExportImportNameKind, ExportLocalNameKind, ImportNameKind, parse, parseSync, rawTransferSupported } = nativeBinding
export { Severity }
export { ParseResult }
export { ExportExportNameKind }
export { ExportImportNameKind }
export { ExportLocalNameKind }
export { ImportNameKind }
export { parse }
export { parseSync }
export { rawTransferSupported }

const { getBufferOffset, parseRaw, parseRawSync } = nativeBinding
export { getBufferOffset, parseRaw, parseRawSync }
