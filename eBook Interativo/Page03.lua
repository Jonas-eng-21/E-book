local composer = require("composer")
local scene = composer.newScene()

-- Variáveis globais para som e controle
local somPag3, somLigado, somChannel

-- Adiciona a flor e a massa na tela
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
        composer.gotoScene("Page04", {
            effect = "fromRight",
            time = 1000
        })
    end)

    local Voltar = display.newImageRect(sceneGroup, "Assets/imagens/botaoAnterior.png", 141, 50)
    Voltar.x = display.contentCenterX - 300
    Voltar.y = display.contentHeight - 100
    Voltar:addEventListener("tap", function()
        composer.gotoScene("Page02", {
            effect = "fromLeft",
            time = 1000
        })
    end)

    -- Botão de som
    local button = display.newImageRect(sceneGroup, "Assets/imagens/off.png", 60, 60)
    button.x = 70
    button.y = 60

    if not somPag3 then
        somPag3 = audio.loadSound("Assets/audios/audioPagina3.mp3")
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
            somChannel = audio.play(somPag3, {
                loops = -1
            })
        end
    end
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

-- Listener de toque duplo simultâneo
local function onDoubleTap(event)
    if event.numTaps == 2 then
        -- Polinizar a flor
        if scene.flor and not scene.flor.isPolinizada then
            scene.flor.isPolinizada = true
            local bee = display.newImageRect(scene.view, "Assets/imagens/bee.png", 40, 40)
            bee.x, bee.y = scene.flor.x, scene.flor.y
            transition.to(bee, {
                y = bee.y - 50,
                alpha = 0,
                time = 1000,
                onComplete = function()
                    bee:removeSelf()
                    scene.flor:setFillColor(0.5, 1, 0.5) -- Flor polinizada
                end
            })
        end

        -- Ativar fermentação na massa
        if scene.massa and not scene.massa.fermentacaoAtiva then
            scene.massa.fermentacaoAtiva = true
            scene.massa:scale(1.5, 1.5) -- Crescimento da massa
            local message = display.newText({
                text = "A fermentação está ativa!",
                x = display.contentCenterX,
                y = display.contentHeight - 150,
                font = native.systemFontBold,
                fontSize = 24
            })
            message:setFillColor(0, 0.8, 0)
            scene.view:insert(message)
            transition.to(message, {
                alpha = 0,
                time = 2000,
                onComplete = function()
                    message:removeSelf()
                end
            })
        end
    end
    return true
end

-- show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        if somChannel then
            audio.pause(somChannel)
        end
    elseif phase == "did" then
        if somLigado then
            somChannel = audio.play(somPag3, {
                loops = -1
            })
        end
        Runtime:addEventListener("tap", onDoubleTap)
    end
end

-- hide()
function scene:hide(event)
    local phase = event.phase

    if phase == "will" then
        if somChannel then
            audio.pause(somChannel)
        end
        Runtime:removeEventListener("tap", onDoubleTap)
    end
end

-- destroy()
function scene:destroy(event)
    if somChannel then
        audio.dispose(somChannel)
    end
    if somPag3 then
        audio.dispose(somPag3)
    end
end

-- Registrar funções de cena no Composer
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
