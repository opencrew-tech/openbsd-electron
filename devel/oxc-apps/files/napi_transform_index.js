import { createRequire } from 'node:module'
const require = createRequire(import.meta.url)

const nativeBinding = require('./transform.node')

const { Severity, HelperMode, isolatedDeclaration, isolatedDeclarationSync, moduleRunnerTransform, moduleRunnerTransformSync, transform, transformSync } = nativeBinding
export { Severity }
export { HelperMode }
export { isolatedDeclaration }
export { isolatedDeclarationSync }
export { moduleRunnerTransform }
export { moduleRunnerTransformSync }
export { transform }
export { transformSync }
