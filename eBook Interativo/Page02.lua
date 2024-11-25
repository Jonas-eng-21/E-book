local composer = require("composer")
local scene = composer.newScene()

local function dragObject(event)
    local object = event.target
    if event.phase == "began" then
        display.getCurrentStage():setFocus(object)
        object.isFocus = true
        object.startX = object.x
        object.startY = object.y
    elseif event.phase == "moved" and object.isFocus then
        object.x = event.x
        object.y = event.y
    elseif event.phase == "ended" or event.phase == "cancelled" then
        if object.isFocus then
            display.getCurrentStage():setFocus(nil)
            object.isFocus = false

            -- Verificar se a vacina foi arrastada para cima de um microrganismo
            for _, microorganism in ipairs(scene.microorganisms) do
                local dx = object.x - microorganism.x
                local dy = object.y - microorganism.y
                local distance = math.sqrt(dx * dx + dy * dy)
                if distance < 50 then -- Distância suficiente para considerar um "combate"
                    microorganism:removeSelf()
                    table.remove(scene.microorganisms, _)
                    break
                end
            end
        end
    end
    return true
end

function scene:create(event)
    local sceneGroup = self.view

    -- Fundo
    local imgFundo = display.newImageRect(sceneGroup, "Assets/imagens/Pag2.png", display.contentWidth,
        display.contentHeight)
    imgFundo.x = display.contentCenterX
    imgFundo.y = display.contentCenterY

    -- Botões de navegação
    local Avancar = display.newImageRect(sceneGroup, "Assets/imagens/botaoProximo.png", 141, 50)
    Avancar.x = display.contentCenterX + 300
    Avancar.y = display.contentHeight - 100
    Avancar:addEventListener("tap", function()
        composer.gotoScene("Page03", {
            effect = "fromRight",
            time = 1000
        })
    end)

    -- Botão "Anterior"
    local Voltar = display.newImageRect(sceneGroup, "Assets/imagens/botaoAnterior.png", 141, 50)
    Voltar.x = display.contentCenterX - 300
    Voltar.y = display.contentHeight - 100
    Voltar:addEventListener("tap", function()
        composer.gotoScene("Page01", {
            effect = "fromLeft",
            time = 1000
        })
    end)

    local button = display.newImageRect(sceneGroup, "Assets/imagens/off.png", 60, 60)
    button.x = 70
    button.y = 60

    if not somPag2 then
        somPag2 = audio.loadSound("Assets/audios/audioPagina2.mp3")
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
            somChannel = audio.play(somPag2, {
                loops = -1
            })
        end
    end
    button:addEventListener("tap", toggleSound)

    -- Vacina
    local vacina = display.newImageRect(sceneGroup, "Assets/imagens/vacina1.png", 80, 80)
    vacina.x = 100
    vacina.y = display.contentHeight - 250
    vacina:addEventListener("touch", dragObject)

    -- Microrganismos
    scene.microorganisms = {}
    local microorganismData = {{
        filename = "Assets/imagens/microrganismos.png",
        x = 470,
        y = 900
    }, {
        filename = "Assets/imagens/microorganismo2.png",
        x = 300,
        y = 650
    }, {
        filename = "Assets/imagens/microorganismo1.png",
        x = 450,
        y = 600
    }}

    for _, data in ipairs(microorganismData) do
        local microorganism = display.newImageRect(sceneGroup, data.filename, 80, 80)
        microorganism.x = data.x
        microorganism.y = data.y
        table.insert(scene.microorganisms, microorganism)
    end
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
            somChannel = audio.play(somPag2, {
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
    if somPag2 then
        audio.dispose(somPag2)
    end
end

function scene:show(event)
    local phase = event.phase

    if phase == "did" then
        -- Qualquer código adicional quando a cena aparecer
    end
end

function scene:hide(event)
    local phase = event.phase

    if phase == "will" then
        -- Qualquer código adicional antes da cena desaparecer
    end
end

function scene:destroy(event)
    -- Limpeza de recursos da cena
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
