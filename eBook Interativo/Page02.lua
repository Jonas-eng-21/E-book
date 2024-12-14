local composer = require("composer")
local scene = composer.newScene()

local somChannel
local somPag2
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
        somLigado = false -- Define som como desligado
        updateSoundIcon() -- Atualiza o ícone do som
        if somChannel then
            audio.pause(somChannel) -- Pausa o som
        end
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
        somLigado = false -- Define som como desligado
        updateSoundIcon() -- Atualiza o ícone do som
        if somChannel then
            audio.pause(somChannel) -- Pausa o som
        end
        composer.gotoScene("Page01", {
            effect = "fromLeft",
            time = 1000
        })
    end)

    -- Botão de som
    button = display.newImageRect(sceneGroup, "Assets/imagens/off.png", 60, 60) -- Começa no estado "off"
    button.x = 70
    button.y = 60

    if not somPag2 then
        somPag2 = audio.loadSound("Assets/audios/audioPagina2.mp3")
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
            somChannel = audio.play(somPag2, {
                loops = -1
            })
        end
        updateSoundIcon() -- Atualiza o ícone de acordo com o estado atual
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
    local phase = event.phase

    if (phase == "will") then
        if somChannel then
            audio.pause(somChannel)
        end
    elseif (phase == "did") then
        -- Som não será reproduzido automaticamente; depende do botão
    end
end

-- hide()
function scene:hide(event)
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
    if somPag2 then
        audio.dispose(somPag2)
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
