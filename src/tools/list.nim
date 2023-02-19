#[ 
 Copyright 2023 ecorous
 
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
import std/[
    os,
    sequtils
]
import parsetoml
import markdown

# copied and modified from stackoverflow: https://stackoverflow.com/a/69668419
proc scanFolder (tgPath: string): seq[string] =
    var
        fileNames: seq[string]
        path, name, ext: string
        
    for kind, obj in walkDir tgPath:
    
        if $kind == "pcDir" :
            fileNames = concat(fileNames, scanFolder(obj))

        (path, name, ext) = splitFile(obj)

        fileNames.add(obj)

    return fileNames 

proc getMarkdown(packToml: string, outDir: string): string =
    var resultx = ""
    discard existsOrCreateDir outDir
    let modsDir = pack_toml / ".." / "mods"
    if dirExists modsDir:
        let modFiles = scanFolder modsDir
        echo modFiles.len
        let b: bool = modFiles.len == 0
        if not b:
            resultx = resultx & "# Mods\n"
            for modFile in modFiles:
                let toml = parseFile(modFile)
                resultx = resultx & "* " & $toml["name"] & "\n"
    let resourcePacksDir = pack_toml / ".." / "resourcepacks"
    if dirExists resourcePacksDir:
        let resourcePackFiles = scanFolder resourcePacksDir
        let b: bool = resourcePackFiles.len == 0
        if not b:
            resultx = resultx & "# Resource Packs\n"
            for resourcePackFile in resourcePackFiles:
                let toml = parseFile(resourcePackFile)
                resultx = resultx & "* " & $toml["name"] & "\n"
    let pluginsDir = pack_toml / ".." / "plugins"
    if dirExists pluginsDir:
        let pluginFiles = scanFolder pluginsDir
        let b: bool = pluginFiles.len == 0
        if not b:
            resultx = resultx & "# Plugins\n"
            for pluginFile in pluginFiles:
                let toml = parseFile(pluginFile)
                resultx = resultx & "* " & $toml["name"] & "\n"
    return resultx

proc generate(genHtml=false, genMarkdown=true, packToml = getCurrentDir() / "pack.toml", outDir = getCurrentDir() / "out") =
    let md = getMarkdown(packToml, outDir);
    echo md
    if genMarkdown:
        writeFile(outDir / "output.md", md)
    if genHtml:
        writeFile(outDir / "output.html", markdown(md))
    

when isMainModule:
    import cligen; dispatch generate;