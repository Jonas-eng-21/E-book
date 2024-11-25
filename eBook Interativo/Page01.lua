local composer = require("composer")
local scene = composer.newScene()

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

function scene:create(event)
    local sceneGroup = self.view

    local imgFundo = display.newImageRect(sceneGroup, "Assets/imagens/Pag1.png", display.contentWidth,
        display.contentHeight)
    imgFundo.x = display.contentCenterX
    imgFundo.y = display.contentCenterY

    local Avancar = display.newImageRect(sceneGroup, "Assets/imagens/botaoProximo.png", 141, 50)
    Avancar.x = display.contentCenterX + 300
    Avancar.y = display.contentHeight - 100
    Avancar:addEventListener("tap", function()
        composer.gotoScene("Page02", {
            effect = "fromRight",
            time = 1000
        })
    end)

    local Voltar = display.newImageRect(sceneGroup, "Assets/imagens/botaoAnterior.png", 141, 50)
    Voltar.x = display.contentCenterX - 300
    Voltar.y = display.contentHeight - 100
    Voltar:addEventListener("tap", function()
        composer.gotoScene("Capa", { effect = "fromLeft", time = 1000 })
    end)

    local button = display.newImageRect(sceneGroup, "Assets/imagens/off.png", 60, 60)
    button.x = 70
    button.y = 60

    if not somPag1 then
        somPag1 = audio.loadSound("Assets/audios/audioPagina1.mp3")
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
            somChannel = audio.play(somPag1, {
                loops = -1
            })
        end
    end
    button:addEventListener("tap", toggleSound)

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

        icon:addEventListener("touch", showInfo)

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

scene:addEventListener("create", scene)

return scene
