local composer = require("composer")
local scene = composer.newScene()

-- Variáveis para armazenar moléculas e fases
local molecules = {}
local stages = {}
local accelerometerEvent
local lastMessageTime = 0 -- Controle de tempo da mensagem
local messageInterval = 5000 -- Intervalo de 5 segundos entre mensagens

-- Função para criar as moléculas
local function createMolecules(sceneGroup)
    local moleculeData = {{
        filename = "Assets/imagens/carbono.png",
        x = display.contentCenterX - 100,
        y = display.contentCenterY
    }, {
        filename = "Assets/imagens/nitrogenio.png",
        x = display.contentCenterX + 100,
        y = display.contentCenterY
    }}

    for _, data in ipairs(moleculeData) do
        local molecule = display.newImageRect(sceneGroup, data.filename, 50, 50)
        molecule.x = data.x
        molecule.y = data.y
        molecule.stageIndex = 1 -- Começa na primeira fase
        table.insert(molecules, molecule)
    end
end

-- Função para criar as fases do ciclo
local function createStages(sceneGroup)
    local stageData = {{
        name = "Planta",
        x = display.contentCenterX - 200,
        y = 200
    }, {
        name = "Consumidor",
        x = display.contentCenterX,
        y = 200
    }, {
        name = "Decompositor",
        x = display.contentCenterX + 200,
        y = 200
    }}

    for _, data in ipairs(stageData) do
        local stage = display.newCircle(sceneGroup, data.x, data.y, 60)
        stage:setFillColor(0.8, 0.8, 0.8, 0.5)
        stage.name = data.name
        table.insert(stages, stage)
    end
end

-- Função para detectar a conclusão do ciclo
local function checkCycleCompletion()
    for _, molecule in ipairs(molecules) do
        if molecule.stageIndex < #stages then
            return false -- Ainda não passou por todas as etapas
        end
    end

    local currentTime = system.getTimer()
    if currentTime - lastMessageTime > messageInterval then
        lastMessageTime = currentTime

        -- Se todas as moléculas completarem o ciclo
        local completionMessage = display.newText({
            text = "Ciclo Completo! Biodiversidade em Equilíbrio!",
            x = display.contentCenterX,
            y = display.contentHeight - 100,
            font = native.systemFontBold,
            fontSize = 20
        })
        completionMessage:setFillColor(0, 1, 0)

        -- Animação de conclusão
        transition.scaleTo(completionMessage, {
            xScale = 1.5,
            yScale = 1.5,
            time = 1000,
            onComplete = function()
                completionMessage:removeSelf()
            end
        })
    end
end

-- Evento do acelerômetro para movimentar as moléculas
local function onAccelerometer(event)
    for _, molecule in ipairs(molecules) do
        molecule.x = molecule.x + (event.xGravity * 11) -- Velocidade aumentada em 10%
        molecule.y = molecule.y - (event.yGravity * 11)

        -- Limitar movimento às bordas da tela
        if molecule.x < 0 then
            molecule.x = 0
        elseif molecule.x > display.contentWidth then
            molecule.x = display.contentWidth
        end

        if molecule.y < 0 then
            molecule.y = 0
        elseif molecule.y > display.contentHeight then
            molecule.y = display.contentHeight
        end

        -- Verificar se a molécula está sobre uma fase
        for i, stage in ipairs(stages) do
            local dx = molecule.x - stage.x
            local dy = molecule.y - stage.y
            local distance = math.sqrt(dx * dx + dy * dy)

            if distance < 60 and molecule.stageIndex == i then
                molecule.stageIndex = molecule.stageIndex + 1 -- Avançar para a próxima fase
                molecule:setFillColor(0, 1, 0) -- Mudar cor para indicar progresso
                break
            end
        end
    end

    checkCycleCompletion()
end

-- Cena: criar
function scene:create(event)
    local sceneGroup = self.view

    -- Fundo
    local imgFundo = display.newImageRect(sceneGroup, "Assets/imagens/Pag4.png", display.contentWidth,
        display.contentHeight)
    imgFundo.x = display.contentCenterX
    imgFundo.y = display.contentCenterY

    -- Criar moléculas e fases
    createMolecules(sceneGroup)
    createStages(sceneGroup)

    -- Botões de navegação
    local Avancar = display.newImageRect(sceneGroup, "Assets/imagens/botaoProximo.png", 141, 50)
    Avancar.x = display.contentCenterX + 300
    Avancar.y = display.contentHeight - 100
    Avancar:addEventListener("tap", function()
        composer.gotoScene("Page05", {
            effect = "fromRight",
            time = 1000
        })
    end)

    local Voltar = display.newImageRect(sceneGroup, "Assets/imagens/botaoAnterior.png", 141, 50)
    Voltar.x = display.contentCenterX - 300
    Voltar.y = display.contentHeight - 100
    Voltar:addEventListener("tap", function()
        composer.gotoScene("Page03", {
            effect = "fromLeft",
            time = 1000
        })
    end)

    local button = display.newImageRect(sceneGroup, "Assets/imagens/off.png", 60, 60)
    button.x = 70
    button.y = 60

    if not somPag4 then
        somPag4 = audio.loadSound("Assets/audios/audioPagina4.mp3")
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
            somChannel = audio.play(somPag4, {
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
            somChannel = audio.play(somPag4, {
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
    if somPag4 then
        audio.dispose(somPag4)
    end
end


-- Cena: exibir
function scene:show(event)
    local phase = event.phase
    if phase == "did" then
        -- Ativar acelerômetro
        Runtime:addEventListener("accelerometer", onAccelerometer)
    end
end

-- Cena: esconder
function scene:hide(event)
    local phase = event.phase
    if phase == "will" then
        -- Remover o acelerômetro ao sair da cena
        Runtime:removeEventListener("accelerometer", onAccelerometer)
    end
end

-- Cena: destruir
function scene:destroy(event)
    -- Limpeza de recursos
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
