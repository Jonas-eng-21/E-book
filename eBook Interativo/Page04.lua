local composer = require("composer")
local scene = composer.newScene()

local molecules = {}
local stages = {}
local accelerometerEvent
local lastMessageTime = 0
local messageInterval = 5000

local function createMolecules(sceneGroup)
    local moleculeData = {{
        filename = "Assets/imagens/carbono.png",
        x = display.contentCenterX - 100,
        y = display.contentCenterY
    }, {
        filename = "Assets/imagens/nitrogenio.png",
        x = display.contentCenterX + 100,
        y = display.contentCenterY
    }}

    for _, data in ipairs(moleculeData) do
        local molecule = display.newImageRect(sceneGroup, data.filename, 50, 50)
        molecule.x = data.x
        molecule.y = data.y
        molecule.stageIndex = 1
        table.insert(molecules, molecule)
    end
end

local function createStages(sceneGroup)
    local stageData = {{
        name = "Planta",
        x = display.contentCenterX - 200,
        y = 200
    }, {
        name = "Consumidor",
        x = display.contentCenterX,
        y = 200
    }, {
        name = "Decompositor",
        x = display.contentCenterX + 200,
        y = 200
    }}

    for _, data in ipairs(stageData) do
        local stage = display.newCircle(sceneGroup, data.x, data.y, 60)
        stage:setFillColor(0.8, 0.8, 0.8, 0.5)
        stage.name = data.name
        table.insert(stages, stage)
    end
end

local function checkCycleCompletion()
    for _, molecule in ipairs(molecules) do
        if molecule.stageIndex < #stages then
            return false
        end
    end

    local currentTime = system.getTimer()
    if currentTime - lastMessageTime > messageInterval then
        lastMessageTime = currentTime

        local completionMessage = display.newText({
            text = "Ciclo Completo! Biodiversidade em Equilíbrio!",
            x = display.contentCenterX,
            y = display.contentHeight - 100,
            font = native.systemFontBold,
            fontSize = 20
        })
        completionMessage:setFillColor(0, 1, 0)

        transition.scaleTo(completionMessage, {
            xScale = 1.5,
            yScale = 1.5,
            time = 1000,
            onComplete = function()
                completionMessage:removeSelf()
            end
        })
    end
end

local function onAccelerometer(event)
    for _, molecule in ipairs(molecules) do
        molecule.x = molecule.x + (event.xGravity * 11)
        molecule.y = molecule.y - (event.yGravity * 11)

        if molecule.x < 0 then
            molecule.x = 0
        elseif molecule.x > display.contentWidth then
            molecule.x = display.contentWidth
        end

        if molecule.y < 0 then
            molecule.y = 0
        elseif molecule.y > display.contentHeight then
            molecule.y = display.contentHeight
        end

        for i, stage in ipairs(stages) do
            local dx = molecule.x - stage.x
            local dy = molecule.y - stage.y
            local distance = math.sqrt(dx * dx + dy * dy)

            if distance < 60 and molecule.stageIndex == i then
                molecule.stageIndex = molecule.stageIndex + 1
                molecule:setFillColor(0, 1, 0)
                break
            end
        end
    end

    checkCycleCompletion()
end

function scene:create(event)
    local sceneGroup = self.view

    local imgFundo = display.newImageRect(sceneGroup, "Assets/imagens/Pag4.png", display.contentWidth,
        display.contentHeight)
    imgFundo.x = display.contentCenterX
    imgFundo.y = display.contentCenterY

    createMolecules(sceneGroup)
    createStages(sceneGroup)

    local Avancar = display.newImageRect(sceneGroup, "Assets/imagens/botaoProximo.png", 141, 50)
    Avancar.x = display.contentCenterX + 300
    Avancar.y = display.contentHeight - 100
    Avancar:addEventListener("tap", function()
        composer.gotoScene("Page05", {
            effect = "fromRight",
            time = 1000
        })
    end)

    local Voltar = display.newImageRect(sceneGroup, "Assets/imagens/botaoAnterior.png", 141, 50)
    Voltar.x = display.contentCenterX - 300
    Voltar.y = display.contentHeight - 100
    Voltar:addEventListener("tap", function()
        composer.gotoScene("Page03", {
            effect = "fromLeft",
            time = 1000
        })
    end)

    local button = display.newImageRect(sceneGroup, "Assets/imagens/off.png", 60, 60)
    button.x = 70
    button.y = 60

    if not somPag4 then
        somPag4 = audio.loadSound("Assets/audios/audioPagina4.mp3")
    end

    local function toggleSound()
        if somLigado then
            somLigado = false
            button.fill = {
                type = "image",
                filename = "Assets/imagens/off.png"
            }
            if somChannel then
                audio.pause(somChannel)
            end
        else
            somLigado = true
            button.fill = {
                type = "image",
                filename = "Assets/imagens/on.png"
            }
            somChannel = audio.play(somPag4, {
                loops = -1
            })
        end
    end
    button:addEventListener("tap", toggleSound)

end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        if somChannel then
            audio.pause(somChannel)
        end
    elseif (phase == "did") then
        if somLigado then
            somChannel = audio.play(somPag4, {
                loops = -1
            })
        end
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        if somChannel then
            audio.pause(somChannel)
        end
    end
end

function scene:destroy(event)
    local sceneGroup = self.view
    if somChannel then
        audio.dispose(somChannel)
    end
    if somPag4 then
        audio.dispose(somPag4)
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
