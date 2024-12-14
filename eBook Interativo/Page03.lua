local composer = require("composer")
local scene = composer.newScene()

-- Variáveis globais para som e controle
local somPag3, somLigado, somChannel
local button -- Declaração do botão de som

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

-- Função para alternar o som
local function toggleSound()
    if somLigado then
        somLigado = false
        updateSoundIcon() -- Atualiza o ícone de som para off
        if somChannel then
            audio.pause(somChannel) -- Pausa o som
        end
    else
        somLigado = true
        updateSoundIcon() -- Atualiza o ícone de som para on
        somChannel = audio.play(somPag3, {
            loops = -1
        })
    end
end

function scene:create(event)
    local sceneGroup = self.view

    -- Fundo
    local imgFundo = display.newImageRect(sceneGroup, "Assets/imagens/Pag3.png", display.contentWidth,
        display.contentHeight)
    imgFundo.x = display.contentCenterX
    imgFundo.y = display.contentCenterY

    -- Botões de navegação
    local Avancar = display.newImageRect(sceneGroup, "Assets/imagens/botaoProximo.png", 141, 50)
    Avancar.x = display.contentCenterX + 300
    Avancar.y = display.contentHeight - 100
    Avancar:addEventListener("tap", function()
        -- Pausa o som ao avançar
        if somChannel then
            audio.pause(somChannel)
        end
        composer.gotoScene("Page04", {
            effect = "fromRight",
            time = 1000
        })
    end)

    local Voltar = display.newImageRect(sceneGroup, "Assets/imagens/botaoAnterior.png", 141, 50)
    Voltar.x = display.contentCenterX - 300
    Voltar.y = display.contentHeight - 100
    Voltar:addEventListener("tap", function()
        -- Pausa o som ao voltar
        if somChannel then
            audio.pause(somChannel)
        end
        composer.gotoScene("Page02", {
            effect = "fromLeft",
            time = 1000
        })
    end)

    -- Botão de som
    button = display.newImageRect(sceneGroup, "Assets/imagens/off.png", 60, 60) -- Começa no estado "off"
    button.x = 70
    button.y = 60

    if not somPag3 then
        somPag3 = audio.loadSound("Assets/audios/audioPagina3.mp3")
    end

    -- Listener para alternar o som
    button:addEventListener("tap", toggleSound)

    -- Adicionar uma flor
    scene.flor = display.newImageRect(sceneGroup, "Assets/imagens/flor.png", 60, 60)
    scene.flor.x = display.contentCenterX - 100
    scene.flor.y = display.contentCenterY
    scene.flor.isPolinizada = false

    -- Adicionar uma massa
    scene.massa = display.newImageRect(sceneGroup, "Assets/imagens/massa.png", 150, 100)
    scene.massa.x = display.contentCenterX + 100
    scene.massa.y = display.contentCenterY
    scene.massa.fermentacaoAtiva = false
end

function scene:show(event)
    local phase = event.phase
    if phase == "will" then
        if somChannel then
            audio.pause(somChannel) -- Pausa o som ao entrar na cena
        end
    elseif phase == "did" then
        if somLigado then
            somChannel = audio.play(somPag3, {
                loops = -1
            }) -- Reproduz o som se estiver ligado
        end
    end
end

function scene:hide(event)
    local phase = event.phase
    if phase == "will" then
        if somChannel then
            audio.pause(somChannel) -- Pausa o som ao sair da cena
        end
    end
end

function scene:destroy(event)
    if somChannel then
        audio.dispose(somChannel) -- Libera o canal de áudio
    end
    if somPag3 then
        audio.dispose(somPag3) -- Libera o som
    end
end

-- Registrar funções de cena no Composer
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
