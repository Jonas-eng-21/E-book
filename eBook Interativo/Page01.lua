local composer = require("composer")
local scene = composer.newScene()

local somChannel
local somPag1
local somLigado = false -- Som começa desligado por padrão

local button -- Declara o botão de som para poder manipulá-lo globalmente

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

local function showInfo(event)
    if event.phase == "ended" then
        local organism = event.target
        local infoText = display.newText({
            text = organism.info,
            x = display.contentCenterX,
            y = display.contentHeight - 100,
            width = display.contentWidth - 40,
            font = native.systemFont,
            fontSize = 18,
            align = "center"
        })
        infoText:setFillColor(0, 0, 0)

        timer.performWithDelay(3000, function()
            display.remove(infoText)
        end)
    end
    return true
end

local function playVideo(videoPath, sceneGroup, infoText)
    local video = native.newVideo(display.contentCenterX, display.contentCenterY, 300, 200)
    video:load(videoPath)
    video:play()

    video:addEventListener("video", function(event)
        if event.phase == "ended" then
            video:removeSelf()
            display.remove(infoText)
        end
    end)

    sceneGroup:insert(video)
end

local function showInfoAndPlayVideo(event)
    if event.phase == "ended" then
        local organism = event.target
        local infoText = display.newText({
            text = organism.info,
            x = display.contentCenterX,
            y = display.contentHeight - 100,
            width = display.contentWidth - 40,
            font = native.systemFont,
            fontSize = 18,
            align = "center"
        })
        infoText:setFillColor(0, 0, 0)

        local videoPaths = {
            ["Assets/imagens/planta.png"] = "Assets/videos/PlantaFzdFotossinteze.mp4",
            ["Assets/imagens/animal.png"] = "Assets/videos/OncaNaFloresta.mp4",
            ["Assets/imagens/fungo.png"] = "Assets/videos/fungoacao.mp4",
            ["Assets/imagens/microrganismos.png"] = "Assets/videos/microorganismoVideo.mp4"
        }

        local videoPath = videoPaths[organism.filename]
        if videoPath then
            playVideo(videoPath, scene.view, infoText)
        end

        timer.performWithDelay(3000, function()
            if infoText and infoText.removeSelf then
                infoText:removeSelf()
            end
        end)
    end
    return true
end

function scene:create(event)
    local sceneGroup = self.view

    -- Fundo da página
    local imgFundo = display.newImageRect(sceneGroup, "Assets/imagens/Pag1.png", display.contentWidth,
        display.contentHeight)
    imgFundo.x = display.contentCenterX
    imgFundo.y = display.contentCenterY

    -- Botão para avançar
    local Avancar = display.newImageRect(sceneGroup, "Assets/imagens/botaoProximo.png", 141, 50)
    Avancar.x = display.contentCenterX + 300
    Avancar.y = display.contentHeight - 100
    Avancar:addEventListener("tap", function()
        somLigado = false -- Define som como desligado
        updateSoundIcon() -- Atualiza o ícone do som
        if somChannel then
            audio.pause(somChannel) -- Pausa o som
        end
        composer.gotoScene("Page02", {
            effect = "fromRight",
            time = 1000
        })
    end)

    -- Botão para voltar
    local Voltar = display.newImageRect(sceneGroup, "Assets/imagens/botaoAnterior.png", 141, 50)
    Voltar.x = display.contentCenterX - 300
    Voltar.y = display.contentHeight - 100
    Voltar:addEventListener("tap", function()
        somLigado = false -- Define som como desligado
        updateSoundIcon() -- Atualiza o ícone do som
        if somChannel then
            audio.pause(somChannel) -- Pausa o som
        end
        composer.gotoScene("Capa", {
            effect = "fromLeft",
            time = 1000
        })
    end)

    -- Botão de som
    button = display.newImageRect(sceneGroup, "Assets/imagens/off.png", 60, 60) -- Começa no estado "off"
    button.x = 70
    button.y = 60

    if not somPag1 then
        somPag1 = audio.loadSound("Assets/audios/audioPagina1.mp3")
    end

    -- Função de alternância do som
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
            somChannel = audio.play(somPag1, {
                loops = -1
            })
        end
        updateSoundIcon() -- Atualiza o ícone de acordo com o estado atual
    end
    button:addEventListener("tap", toggleSound)

    -- Organismos
    local organisms = {{
        name = "Planta",
        info = "Produz oxigênio para o ecossistema.",
        x = 180,
        y = 600,
        filename = "Assets/imagens/planta.png"
    }, {
        name = "Animal",
        info = "Contribui para a cadeia alimentar.",
        x = 300,
        y = 600,
        filename = "Assets/imagens/animal.png"
    }, {
        name = "Fungo",
        info = "Decompõe matéria orgânica.",
        x = 410,
        y = 600,
        filename = "Assets/imagens/fungo.png"
    }, {
        name = "Microrganismo",
        info = "Ajuda na reciclagem de nutrientes.",
        x = 540,
        y = 600,
        filename = "Assets/imagens/microrganismos.png"
    }}

    for i, org in ipairs(organisms) do
        local icon = display.newImageRect(sceneGroup, org.filename, 120, 120)
        icon.x = org.x
        icon.y = org.y

        icon.info = org.info
        icon.filename = org.filename

        icon:addEventListener("touch", showInfoAndPlayVideo)

        local label = display.newText({
            parent = sceneGroup,
            text = org.name,
            x = org.x,
            y = org.y + 70,
            font = native.systemFont,
            fontSize = 14,
            align = "center"
        })
        label:setFillColor(0, 0, 0)
    end
end

function scene:show(event)
    local phase = event.phase
    if phase == "did" then
        -- Som não será reproduzido automaticamente; depende do botão
    elseif phase == "will" then
        if somChannel then
            audio.pause(somChannel)
        end
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)

return scene
