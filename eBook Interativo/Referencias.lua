local composer = require("composer")
local scene = composer.newScene()

local somCapa
local somChannel
local somLigado = false
local button -- Declarar o botão para manipulação global

-- Função para atualizar o ícone do som conforme o estado
local function updateSoundIcon()
    if somLigado then
        button.fill = {
            type = "image",
            filename = "Assets/imagens/on.png"
        }
    else
        button.fill = {
            type = "image",
            filename = "Assets/imagens/off.png"
        }
    end
end

function scene:create(event)
    local sceneGroup = self.view

    local imgCapa = display.newImageRect(sceneGroup, "Assets/imagens/referencias.png", display.contentWidth,
        display.contentHeight)
    imgCapa.x = display.contentCenterX
    imgCapa.y = display.contentCenterY

    -- Botão "Próximo"
    local Avancar = display.newImageRect(sceneGroup, "Assets/imagens/inicio.png", 141, 50)
    Avancar.x = display.contentCenterX + 300
    Avancar.y = display.contentHeight - 100
    Avancar:addEventListener("tap", function()
        somLigado = false -- Define som como desligado
        updateSoundIcon() -- Atualiza o ícone do som
        if somChannel then
            audio.pause(somChannel) -- Pausa o som
        end
        composer.gotoScene("Capa", {
            effect = "fromRight",
            time = 1000
        })
    end)

    -- Botão "Anterior"
    local Voltar = display.newImageRect(sceneGroup, "Assets/imagens/botaoAnterior.png", 141, 50)
    Voltar.x = display.contentCenterX - 300
    Voltar.y = display.contentHeight - 100
    Voltar:addEventListener("tap", function()
        somLigado = false -- Define som como desligado
        updateSoundIcon() -- Atualiza o ícone do som
        if somChannel then
            audio.pause(somChannel) -- Pausa o som
        end
        composer.gotoScene("ContraCapa", {
            effect = "fromLeft",
            time = 1000
        })
    end)

    -- Botão de som
    button = display.newImageRect(sceneGroup, "Assets/imagens/off.png", 60, 60) -- Começa no estado "off"
    button.x = 70
    button.y = 60

    -- Carregar o áudio, caso ainda não tenha sido carregado
    if not somCapa then
        somCapa = audio.loadSound("Assets/audios/audioReferencias.mp3")
    end

    -- Função de alternância do som
    local function toggleSound()
        if somLigado then
            -- Desativa o som
            somLigado = false
            updateSoundIcon() -- Atualiza o ícone do som
            if somChannel then
                audio.pause(somChannel) -- Pausa o som
            end
        else
            -- Ativa o som
            somLigado = true
            somChannel = audio.play(somCapa, {
                loops = -1
            })
            updateSoundIcon() -- Atualiza o ícone do som
        end
    end
    button:addEventListener("tap", toggleSound)
end

-- show()
function scene:show(event)
    local phase = event.phase
    if (phase == "will") then
        if somChannel then
            audio.pause(somChannel) -- Pausa o som ao mudar para a cena
        end
    elseif (phase == "did") then
        -- O som só será reproduzido se o usuário ativar
        if somLigado then
            somChannel = audio.play(somCapa, {
                loops = -1
            })
        end
    end
end

-- hide()
function scene:hide(event)
    local phase = event.phase
    if (phase == "will") then
        if somChannel then
            audio.pause(somChannel) -- Pausa o som quando sair da cena
        end
    end
end

-- destroy()
function scene:destroy(event)
    local sceneGroup = self.view
    if somChannel then
        audio.dispose(somChannel) -- Libera o áudio
    end
    if somCapa then
        audio.dispose(somCapa) -- Libera o áudio
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
