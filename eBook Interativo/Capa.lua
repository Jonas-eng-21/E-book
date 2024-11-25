local composer = require("composer")

local scene = composer.newScene()
local somCapa
local somChannel
local somLigado = false

function scene:create(event)

    local sceneGroup = self.view
    local imgCapa = display.newImageRect(sceneGroup, "Assets/imagens/capa.png", display.contentWidth,
        display.contentHeight)

    imgCapa.x = display.contentCenterX
    imgCapa.y = display.contentCenterY

    local Avancar = display.newImageRect(sceneGroup, "Assets/imagens/botaoProximo.png", 141, 50)
    Avancar.x = 380
    Avancar.y = 945

    Avancar:addEventListener('tap', function()
        composer.gotoScene("Page01", {
            effect = "fromRight",
            time = 1000
        })
    end)


    local button = display.newImageRect(sceneGroup, "Assets/imagens/off.png", 60, 60)
    button.x = 70
    button.y = 60

    if not somCapa then
        somCapa = audio.loadSound("Assets/audios/audioCapa.mp3")
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
            somChannel = audio.play(somCapa, {
                loops = -1
            })
        end
    end
    button:addEventListener("tap", toggleSound)
end

-- show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        if somChannel then
            audio.pause(somChannel)
        end
    elseif (phase == "did") then
        if somLigado then
            somChannel = audio.play(somCapa, {
                loops = -1
            })
        end
    end
end

-- hide()
function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        if somChannel then
            audio.pause(somChannel)
        end
    elseif (phase == "did") then
    end
end

function scene:destroy(event)
    local sceneGroup = self.view
    if somChannel then
        audio.dispose(somChannel)
    end
    if somCapa then
        audio.dispose(somCapa)
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
