local composer = require("composer")
local scene = composer.newScene()

local somCapa
local somChannel
local somLigado = false

local button -- Declara o botão de som para manipulação global

-- Função para atualizar o ícone do som
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

    -- Fundo da contra capa
    local imgCapa = display.newImageRect(sceneGroup, "Assets/imagens/contracapa.png", display.contentWidth,
        display.contentHeight)
    imgCapa.x = display.contentCenterX
    imgCapa.y = display.contentCenterY

    -- Botão "Próximo"
    local Avancar = display.newImageRect(sceneGroup, "Assets/imagens/btnReferencia.png", 141, 50)
    Avancar.x = display.contentCenterX + 300
    Avancar.y = display.contentHeight - 100
    Avancar:addEventListener("tap", function()
        somLigado = false -- Define som como desligado
        updateSoundIcon() -- Atualiza o ícone do som
        if somChannel then
            audio.pause(somChannel) -- Pausa o som
        end
        composer.gotoScene("Referencias", {
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
        composer.gotoScene("Page05", {
            effect = "fromLeft",
            time = 1000
        })
    end)

    -- Botão de som
    button = display.newImageRect(sceneGroup, "Assets/imagens/off.png", 60, 60) -- Começa no estado "off"
    button.x = 70
    button.y = 60

    if not somCapa then
        somCapa = audio.loadSound("Assets/audios/audioContracapa.mp3")
    end

    -- Função para alternar o som
    local function toggleSound()
        if somLigado then
            -- Desativa o som
            somLigado = false
            if somChannel then
                audio.pause(somChannel)
            end
        else
            -- Ativa o som
            somLigado = true
            somChannel = audio.play(somCapa, {
                loops = -1
            })
        end
        updateSoundIcon() -- Atualiza o ícone de som
    end
    button:addEventListener("tap", toggleSound)
end

function scene:show(event)
    local phase = event.phase

    if (phase == "will") then
        if somChannel then
            audio.pause(somChannel) -- Pausa o som ao sair da cena
        end
    elseif (phase == "did") then
        if somLigado then
            somChannel = audio.play(somCapa, {
                loops = -1
            }) -- Inicia o som se o som estiver ligado
        end
    end
end

function scene:hide(event)
    local phase = event.phase
    if (phase == "will") then
        if somChannel then
            audio.pause(somChannel) -- Pausa o som ao esconder a cena
        end
    end
end

function scene:destroy(event)
    local sceneGroup = self.view
    if somChannel then
        audio.dispose(somChannel) -- Libera o som ao destruir a cena
    end
    if somCapa then
        audio.dispose(somCapa) -- Libera o som da contra capa
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
