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
import std/[
    strutils,
    os
]
type ModLoader* = enum
    None, Fabric, Forge, Quilt

type Side* = enum
    Server, Client, Both

type Source* = enum
    Modrinth, CurseForge

type UpdateData* = object
    versionId*: string
    projectId*: string
    mrUrl*: string
    source*: Source

type Mod* = object
    name*: string
    side*: Side
    filename*: string
    hashFormat*: string
    hash*: string
    updateData*: UpdateData

type Modpack* = object
    packName*: string
    packAuthor*: string
    packVersion*: string
    mcVersion*: string
    modloader*: Modloader
    id*: string
    mods*: seq[Mod]

proc toModLoader*(input: string): Modloader =
    if input.toLowerAscii == "quilt":
        result = Modloader.Quilt
    elif input.toLowerAscii == "fabric":
        result = Modloader.Fabric
    elif input.toLowerAscii == "forge":
        result = Modloader.Forge
    elif input.toLowerAscii == "none" or input.toLowerAscii == "vanilla":
        result = Modloader.None

proc toSource*(input: string): Source =
    if input.toLowerAscii == "modrinth":
        result = Source.Modrinth
    elif input.toLowerAscii == "curseforge":
        result = Source.CurseForge

proc toModSide*(input: string): Side =
    if input.toLowerAscii == "client":
        result = Side.Client
    elif input.toLowerAscii == "server":
        result = Side.Server
    elif input.toLowerAscii == "both":
        result = Side.Both