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
import nigui
import std/httpclient

let logger: Logger = getLogger "packnim_gui".createLoggingSource "windowManager"

proc editPack*(pack: Modpack) =
    var editPackWindow = newWindow "Editing " & pack.packName & " - PackNim"
    
    show editPackWindow

proc packCreate*() =
    var createWindow = newWindow "Create New Pack - PackNim"
    createWindow.width = 400
    createWindow.height = 600
    var createContainer = newLayoutContainer Layout_Vertical

    var nameContainer = newLayoutContainer Layout_Horizontal
    var nameText = newLabel "Pack Name:"
    var nameBox = newTextBox()
    nameContainer.add nameText
    nameContainer.add nameBox
    createContainer.add nameContainer

    var authorContainer = newLayoutContainer Layout_Horizontal
    var authorText = newLabel "Pack Author:"
    var authorBox = newTextBox()
    authorContainer.add authorText
    authorContainer.add authorBox
    createContainer.add authorContainer

    var versionContainer = newLayoutContainer Layout_Horizontal
    var versionText = newLabel "Pack Version:"
    var versionBox = newTextBox()
    versionContainer.add versionText
    versionContainer.add versionBox
    createContainer.add versionContainer

    var mcVersionContainer = newLayoutContainer Layout_Horizontal
    var mcVersionText = newLabel "Pack MC Version:"
    var mcVersionBox = newTextBox()
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
        if loadervChoiceBox.options[loaderBox.index].toModLoader == ModLoader.Quilt or loadervChoiceBox.options[loaderBox.index].toModLoader == ModLoader.Fabric:
            modloaderVersion = loadervChoiceBox.options[loadervChoiceBox.index]
        else:
            modloaderVersion = loadervTextBox.text

        let pack = packwizInit(nameBox.text, authorBox.text, versionBox.text, mcVersionBox.text, loaderBox.options[loaderBox.index].toModLoader, modloaderVersion)
        editPack(pack)
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
    show mainWindowX