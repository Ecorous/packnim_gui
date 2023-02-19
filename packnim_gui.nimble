# Package

version       = "0.1.0"
author        = "Ecorous"
description   = "Packwiz GUI made with NIM"
license       = "Apache-2.0"
srcDir        = "src"
binDir        = "build"
bin           = @["packnim", "tools/list"]


# Dependencies

requires "nim >= 1.6.10"
requires "cligen >= 1.5.39"
requires "nigui >= 0.2.6"
requires "parsetoml"
requires "markdown >= 0.8.5"