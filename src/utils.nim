# Copyright 2023 ecorous
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import ./logging
import std/strutils
import std/httpclient
import nigui
import std/json

let quiltMetaServer = "https://meta.quiltmc.org/v3/"
let fabricMetaServer = "https://meta.fabricmc.net/v2/"
var client* = newHttpClient()
var alertWindow*: Window # Rely on window.nim to set this

proc alertError*(logger: Logger, message: varargs[string]) = 
    alertWindow.alert message.join("")
    logger.error message

proc getQuiltVersions*(): seq[string] =
    result = @[]
    var url = quiltMetaServer & "versions/loader"
    let response = client.getContent url
    let x = json.parseJson response
    for node in x.items:
        result.add node{"version"}.getStr "NIL"

proc getFabricVersions*(): seq[string] =
    result = @[]
    var url = fabricMetaServer & "versions/loader"
    let response = client.getContent url
    let x = json.parseJson response
    for node in x.items:
        result.add node{"version"}.getStr "NIL"
    

proc getMainWindow*(): Window = 
    alertWindow