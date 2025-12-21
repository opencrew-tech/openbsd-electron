// prettier-ignore
/* eslint-disable */
// @ts-nocheck
/* for openbsd use only */

const path = require('path');
const { createRequire } = require('node:module')
require = createRequire(__filename)

let nativeBinding = null
const loadErrors = []

try {
  nativeBinding = require(path.join(__dirname, './tailwindcss-oxide.node'))
} catch (err) {
  loadErrors.push(err);
}

if (!nativeBinding || process.env.NAPI_RS_FORCE_WASI) {
  try {
    nativeBinding = require('./tailwindcss-oxide.wasi.cjs')
  } catch (err) {
    if (process.env.NAPI_RS_FORCE_WASI) {
      loadErrors.push(err)
    }
  }
  if (!nativeBinding) {
    try {
      nativeBinding = require('@tailwindcss/oxide-wasm32-wasi')
    } catch (err) {
      if (process.env.NAPI_RS_FORCE_WASI) {
        loadErrors.push(err)
      }
    }
  }
}

if (!nativeBinding) {
  if (loadErrors.length > 0) {
    // TODO Link to documentation with potential fixes
    //  - The package owner could build/publish bindings for this arch
    //  - The user may need to bundle the correct files
    //  - The user may need to re-install node_modules to get new packages
    throw new Error('Failed to load native binding', { cause: loadErrors })
  }
  throw new Error(`Failed to load native binding`)
}

module.exports.Scanner = nativeBinding.Scanner
