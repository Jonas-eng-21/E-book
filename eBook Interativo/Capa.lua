local composer = require("composer")

local scene = composer.newScene()
local somCapa
local somChannel
local somLigado = false -- Som começa desligado por padrão

function scene:create(event)
    local sceneGroup = self.view

    -- Imagem de fundo
    local imgCapa = display.newImageRect(sceneGroup, "Assets/imagens/capa.png", display.contentWidth,
        display.contentHeight)
    imgCapa.x = display.contentCenterX
    imgCapa.y = display.contentCenterY

    -- Botão para avançar
    local Avancar = display.newImageRect(sceneGroup, "Assets/imagens/botaoProximo.png", 141, 50)
    Avancar.x = 380
    Avancar.y = 945
    Avancar:addEventListener("tap", function()
        composer.gotoScene("Page01", {
            effect = "fromRight",
            time = 1000
        })
    end)

    -- Botão de som (ligar/desligar)
    local button = display.newImageRect(sceneGroup, "Assets/imagens/off.png", 60, 60) -- Ícone inicia como "off"
    button.x = 70
    button.y = 60

    if not somCapa then
        somCapa = audio.loadSound("Assets/audios/audioCapa.mp3")
    end

    local function toggleSound()
        if somLigado then
            -- Desliga o som
            somLigado = false
            button.fill = {
                type = "image",
                filename = "Assets/imagens/off.png"
            }
            if somChannel then
                audio.pause(somChannel)
                somChannel = nil
            end
        else
            -- Liga o som
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

-- Método para quando a cena aparece
function scene:show(event)
    local phase = event.phase

    if (phase == "did") then
        -- O som não será iniciado automaticamente; apenas se o botão for acionado
    end
end

-- Método para quando a cena é escondida
function scene:hide(event)
    local phase = event.phase

    if (phase == "will") then
        -- Parar o áudio ao sair da cena
        if somChannel then
            audio.stop(somChannel)
            somChannel = nil
        end
    end
end

-- Método para quando a cena é destruída
function scene:destroy(event)
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
