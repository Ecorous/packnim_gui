# Package

version       = "0.1.0"
author        = "Ecorous"
description   = "Packwiz GUI made with NIM"
license       = "Apache-2.0"
srcDir        = "src"
binDir        = "build"
bin           = @["packnim", "tools/list"]

task debug, "Build and run a normal debug build":
  --verbose
  --deepcopy:on
  --threads:on
  --define:lto
  --mm:orc
  --define:enableTinyPoolLogging
  --define:normDebug
  --stackTrace:on 
  --lineTrace:on 
  --styleCheck:usages
  --spellSuggest:50
  --excessiveStackTrace:on
  --define:ssl
  --define:verbose
  --outdir:"build/"
  setCommand "c", "src/packnim.nim"

# Dependencies

requires "nim >= 1.6.10"
requires "cligen >= 1.5.39"
requires "nigui >= 0.2.6"
requires "parsetoml"
requires "markdown >= 0.8.5"