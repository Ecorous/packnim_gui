#[
 Copyright 2023 Ecorous System
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
     http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License. 
]#

import std/os
import std/osproc
import std/streams
import strutils
import sequtils
import parsetoml
import ./logging
import ./types
import ./utils

let logger: Logger = getLogger "packwiz-nigui".createLoggingSource "packwiz"

proc `^&`(name: string): string = 
    result = utils.instancesDir / name

proc cleanseName*(name: string): string =
    let evilChars: seq[char] = @['"', '\'', ' ', '!', '\\', '/']
    result = name
    for c in evilChars:
        result = result.replace($c, "_")

proc checkIfPackwiz*(): bool =
    result = "packwiz".findExe != "" or "packwiz.exe".findExe != ""
    if "packwiz.exe".fileExists or "packwiz".fileExists:
        logger.warn "Packwiz in current directory takes priority over packwiz in PATH. Rename or remove the packwiz in current directory to use the packwiz located in PATH"

proc getPackwiz*(): string = 
    when defined windows:
        result = "packwiz.exe"
    else:
        result = "packwiz"
    if not checkIfPackwiz():
        logger.alertError "No packwiz found. Please install packwiz into your PATH or the current directory. Note that PackNim will not work without this."
    if fileExists(result):
        result = absolutePath result
    else:
        result = findExe result

proc getModIdList*(pack: Modpack): seq[string] =
    let path = ^&pack.id
    echo (walkFiles(path / "mods" / "*").toSeq.len != 0)
    for file in walkFiles(path / "mods" / "*"):
        echo file

proc packwizInit*(packName: string = "TestPack", packAuthor: string = "TestAuthor", packVersion: string = "1.0.0", mcVersion: string = "1.19.3", modloader: Modloader = Modloader.None, modloaderVersion: string = ""): Modpack = 
    if not dirExists utils.instancesDir:
        createDir utils.instancesDir;
    if dirExists(^&packName.cleanseName) and (walkFiles(^&packName.cleanseName / "*").toSeq.len != 0):
        utils.currentError = true
        #logger.alertError "Pack directory already exists! Delete " & ^&packName & " or choose a different name"
        logger.alertError "Pack directory already exists! Delete " & ^&packName & " or choose a different name"
    else:
        createDir ^&packName
        var args: seq[string] = @["init", "--name", packName, "--author", packAuthor, "--version", packVersion, "--mc-version", mcVersion, "--modloader", toLowerAscii($modloader)]
        if toLowerAscii($modloader) != "none" and toLowerAscii($modloader) != "vanilla":
            args.add "--" & toLowerAscii($modloader) & "-version"
            args.add modloaderVersion
        result = Modpack(
                            packName: packName,
                            packAuthor: packAuthor,
                            packVersion: packVersion,
                            mcVersion: mcVersion,
                            modloader: modloader,
                            id: packName.cleanseName,
                            mods: @[]
                        )
        let x = startProcess(getPackwiz(), ^&packName, args)
        if x.waitForExit != 0:
            logger.alertError "An error occured while creating the pack."
        let o: owned(Stream) = x.outputStream
        var line = ""
        while o.readLine(line):
            logger.debug line
        

#proc writeFromModpack*(pack: Modpack): bool =
# 

proc toModpack*(path: string): Modpack =
    let splitPath = path.split(DirSep)
    let lastIndex = splitPath.len - 1
    result.id = splitPath[lastIndex]
    let packTomlPath = path / "pack.toml"
    let packToml = parseFile(packTomlPath)
    result.packName = packToml.getStr("name")
    try:
        result.packAuthor = packToml.getStr("author")
    except KeyError:
        discard
    result.packVersion = packToml.getStr("version")
    result.mcVersion = packToml["versions"].getStr("minecraft")
    try:
        discard packToml["versions"].getStr("quilt")
        result.modloader = ModLoader.Quilt
    except KeyError:
        try:
            discard packToml["versions"].getStr("fabric")
            result.modloader = ModLoader.Fabric
        except KeyError:
            try:
                discard packToml["version"].getStr("forge")
                result.modloader = ModLoader.Forge
            except KeyError:
                result.modloader = ModLoader.None