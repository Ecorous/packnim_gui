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

import ./packwiz
import ./types
import ./utils
import ./logging
import os
import nigui
import std/strutils

var delete: bool = false
var globalDeleteConfirm: Window = nil
let logger: Logger = getLogger "packnim_gui".createLoggingSource "windowManager"

proc editPack*(pack: Modpack) =
    echo pack.getModIdList
    var editPackWindow = newWindow "Editing " & pack.packName & " - PackNim"
    var editPackContainer = newLayoutContainer Layout_Vertical
    
    var installModContainer = newLayoutContainer Layout_Horizontal
    var installModGap = newLabel "\t"
    var sourceComboBox = newComboBox @[$Source.Modrinth, $Source.CurseForge]
    var modTextBox = newTextBox()
    var installModButton = newButton "Install Mod"


    installModButton.onclick = proc (event: ClickEvent) =
        editPackWindow.alert "Action not implemented (yet)"
    installModContainer.add sourceComboBox
    installModContainer.add installModGap
    installModContainer.add modTextBox
    installModContainer.add installModButton

    var toggleModsButton = newButton "Toggle Mods Visibility"
    var modsTextArea = newTextArea()
    modsTextArea.editable = false
    hide modsTextArea
    

    editPackContainer.add installModContainer
    editPackWindow.add editPackContainer
    show editPackWindow

proc deleteConfirm*(name: string): Window =
    var x = false
    var deleteConfirmWindow = newWindow "Confirm deletion"
    var lC = newLayoutContainer Layout_Vertical
    lC.add (newLabel "Are you sure you want to delete \"" & name & "\"? THIS ACTION IS IRREVERSIBLE. YOU WILL NOT BE ABLE TO RECOVER THIS.")
    var confirmButton = newButton "Confirm"
    var cancelButton = newButton "Cancel"
    confirmButton.onClick = proc (event: ClickEvent) =
        delete = true
        hide deleteConfirmWindow
        dispose deleteConfirmWindow
    cancelButton.onClick = proc (event: ClickEvent) =
        delete = false
        hide deleteConfirmWindow
        dispose deleteConfirmWindow
    lC.add confirmButton
    lC.add cancelButton
    deleteConfirmWindow.add lC
    show deleteConfirmWindow
    return deleteConfirmWindow

proc openPack*() = 
    var openPackWindow = newWindow "Open Pack - PackNim"
    var openPackContainer = newLayoutContainer Layout_Vertical
    var openPackList = newTextArea()
    var packFolders: seq[string] = @[]
    for folder in walkDirs(utils.instancesDir / "*"):
        let x = folder.split(DirSep)[^1]
        if fileExists(folder / "pack.toml"):
            openPackList.addLine x
            packFolders.add x
    openPackList.addLine "\nTo add a pack to this list, first make sure it has a `pack.toml` in it's directory and that the directory is located in " & utils.instancesDir
    #openPackList.width = 400.scaleToDpi
    #openPackList.height = 100.scaleToDpi
    openPackList.editable = false

    var actionRow = newLayoutContainer Layout_Horizontal

    var packSelectionBox = newComboBox packFolders
    var openButton = newButton "Open"
    var deleteButton = newButton "Delete"

    openButton.onClick = proc (event: ClickEvent) =
        let pack = toModpack(utils.instancesDir / packSelectionBox.options[packSelectionBox.index])
        editPack(pack)
        hide openPackWindow
        dispose openPackWindow
    deleteButton.onClick = proc (event: ClickEvent) = 
        let x = deleteConfirm(packSelectionBox.options[packSelectionBox.index])
        x.onDispose = proc (event: WindowDisposeEvent) =
            echo delete
            if delete:
                removeDir(utils.instancesDir / packSelectionBox.options[packSelectionBox.index])
                packFolders = @[]
                openPackList.text = ""
                for folder in walkDirs(utils.instancesDir / "*"):
                    let x = folder.split(DirSep)[^1]
                    if fileExists(folder / "pack.toml"):
                        openPackList.addLine x
                        packFolders.add x
                openPackList.addLine "\nTo add a pack to this list, first make sure it has a `pack.toml` in it's directory and that the directory is located in " & utils.instancesDir
                packSelectionBox.options = packFolders
                


    actionRow.add packSelectionBox
    actionRow.add openButton
    actionRow.add deleteButton
    openPackContainer.add actionRow
    openPackContainer.add openPackList
    openPackWindow.add openPackContainer
    show openPackWindow

proc packCreate*() =
    var createWindow = newWindow "Create New Pack - PackNim"
    createWindow.width = 400.scaleToDpi
    createWindow.height = 600.scaleToDpi
    var createContainer = newLayoutContainer Layout_Vertical

    var nameContainer = newLayoutContainer Layout_Horizontal
    var nameText = newLabel "Pack Name:"
    var nameBox = newTextBox()
    nameBox.text = "TestPack"
    nameContainer.add nameText
    nameContainer.add nameBox
    createContainer.add nameContainer

    nameBox.onTextChange = proc(event: TextChangeEvent) =
        nameBox.text = cleanseName(nameBox.text)

    var authorContainer = newLayoutContainer Layout_Horizontal
    var authorText = newLabel "Pack Author:"
    var authorBox = newTextBox()
    authorBox.text = "Me!"
    authorContainer.add authorText
    authorContainer.add authorBox
    createContainer.add authorContainer

    var versionContainer = newLayoutContainer Layout_Horizontal
    var versionText = newLabel "Pack Version:"
    var versionBox = newTextBox()
    versionBox.text = "0.1.0"
    versionContainer.add versionText
    versionContainer.add versionBox
    createContainer.add versionContainer

    var mcVersionContainer = newLayoutContainer Layout_Horizontal
    var mcVersionText = newLabel "Pack MC Version:"
    var mcVersionBox = newTextBox()
    mcVersionBox.text = "1.19.3"
    mcVersionContainer.add mcVersionText
    mcVersionContainer.add mcVersionBox
    createContainer.add mcVersionContainer

    var loaderContainer = newLayoutContainer Layout_Horizontal
    var loaderText = newLabel "Mod Loader:"
    let loaders = @[$ModLoader.Quilt, $ModLoader.Fabric, $ModLoader.Forge, $ModLoader.None]
    var loaderBox = newComboBox loaders
    var loadervContainer = newLayoutContainer Layout_Horizontal
    var loadervText = newLabel "Quilt Loader Version:"

    var loaderVersions: seq[string] = getQuiltVersions()
    var loadervChoiceBox = newComboBox loaderVersions
    var loadervTextBox = newTextBox()
    loaderContainer.add loaderText
    loaderContainer.add loaderBox
    loadervContainer.add loadervText
    loadervContainer.add loadervTextBox
    loadervTextBox.hide
    loadervContainer.add loadervChoiceBox
    createContainer.add loaderContainer
    createContainer.add loadervContainer
    
    loaderBox.onChange = proc(event: ComboBoxChangeEvent) =
        loadervText.hide
        loadervTextBox.hide
        loadervChoiceBox.hide
        case loaderBox.options[loaderBox.index]:
            of $ModLoader.Quilt:
                loadervText.text = "Quilt Loader Version:"
                loadervText.show
                loaderVersions = getQuiltVersions()
                loadervChoiceBox.options = loaderVersions
                loadervChoiceBox.show
            of $ModLoader.Fabric:
                loadervText.text = "Fabric Loader Version:"
                loadervText.show
                loaderVersions = getFabricVersions()
                loadervChoiceBox.options = loaderVersions
                loadervChoiceBox.show
            of $ModLoader.Forge:
                loadervText.text = "Forge Version:"
                loadervText.show
                loadervTextBox.show
        createContainer.forceRedraw()
    var submitButton = newButton "Submit"
    createContainer.add submitButton
    submitButton.onClick = proc (event: ClickEvent) =
        var modloaderVersion: string = ""
        if loaderBox.options[loaderBox.index].toModLoader == ModLoader.Quilt or loaderBox.options[loaderBox.index].toModLoader == ModLoader.Fabric:
            modloaderVersion = loadervChoiceBox.options[loadervChoiceBox.index]
        else:
            modloaderVersion = loadervTextBox.text
        utils.currentError = false
        let pack = packwizInit(nameBox.text, authorBox.text, versionBox.text, mcVersionBox.text, loaderBox.options[loaderBox.index].toModLoader, modloaderVersion)
        if not utils.currentError:
            editPack(pack)
            hide createWindow
            dispose createWindow
    createWindow.add createContainer
    show createWindow

proc mainWindow*() = 
    var mainWindowX = newWindow "PackNim"
    utils.alertWindow = mainWindowX
    mainWindowX.width = 600.scaleToDpi
    mainWindowX.height = 400.scaleToDpi
    var container = newLayoutContainer Layout_Vertical

    mainWindowX.add container
    var createNewPackButton = newButton "Create New Pack"
    var gap = newLabel "\n"
    var openPackButton = newButton "Open an Existing Pack"
    container.add createNewPackButton
    container.add gap
    container.add openPackButton
    createNewPackButton.onClick = proc (event: ClickEvent) =
        packCreate()
    openPackButton.onClick = proc (event: ClickEvent) = 
        openPack()
    show mainWindowX