local composer = require("composer")
local scene = composer.newScene()

-- Variáveis para sementes e efeitos
local seeds = {}
local polinators = {}
local seedVelocity = 20
local touchListenerAdded = false -- Controle do listener
local treeOffsetX = 0 -- Controle do deslocamento no eixo X

-- Função para criar o cenário degradado
local function createBackground(sceneGroup)
    local background = display.newImageRect(sceneGroup, "Assets/imagens/Pag5.png", display.contentWidth,
        display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
end

-- Função para lançar uma semente
local function launchSeed(event)
    if event.phase == "began" then
        local seed = display.newImageRect(scene.view, "Assets/imagens/semente.png", 60, 60)
        seed.x = display.contentCenterX
        seed.y = display.contentHeight - 100
        physics.addBody(seed, {
            radius = 10,
            bounce = 0.3
        })

        local angle = math.atan2(event.y - seed.y, event.x - seed.x)
        seed:setLinearVelocity(math.cos(angle) * seedVelocity, math.sin(angle) * seedVelocity)

        table.insert(seeds, seed)

        -- Detectar colisão com o solo
        function seed:collision(event)
            if event.phase == "began" then
                if event.other.name == "ground" then
                    -- Adicionar deslocamento no eixo X
                    treeOffsetX = treeOffsetX + math.random(-200, 200)

                    -- Criar uma árvore
                    local tree = display.newImageRect(scene.view, "Assets/imagens/arvore.png", 200, 220)
                    tree.x = seed.x + treeOffsetX
                    tree.y = seed.y - 120

                    -- Remover semente
                    seed:removeSelf()

                    -- Ativar animação de polinizadores
                    for i = 1, 3 do
                        local polinator = display.newImageRect(scene.view, "Assets/imagens/polinizador.png", 50, 50)
                        polinator.x = tree.x
                        polinator.y = tree.y
                        transition.to(polinator, {
                            x = tree.x + math.random(-50, 50),
                            y = tree.y + math.random(-50, 50),
                            time = 1000,
                            onComplete = function()
                                polinator:removeSelf()
                            end
                        })
                        table.insert(polinators, polinator)
                    end

                    -- Mensagem de recuperação do ecossistema
                    local message = display.newText({
                        text = "O ecossistema está se regenerando!",
                        x = display.contentCenterX,
                        y = display.contentHeight - 50,
                        font = native.systemFontBold,
                        fontSize = 20
                    })
                    message:setFillColor(0, 1, 0)
                    transition.fadeOut(message, {
                        time = 2000,
                        onComplete = function()
                            message:removeSelf()
                        end
                    })
                end
            end
        end

        seed:addEventListener("collision")
    end
end

-- Função para criar o solo
local function createGround(sceneGroup)
    local ground = display.newRect(sceneGroup, display.contentCenterX, display.contentHeight - 20, display.contentWidth,
        40)
    ground:setFillColor(0.4, 0.2, 0.1)
    physics.addBody(ground, "static", {
        bounce = 0.0
    })
    ground.name = "ground"
end

-- Criar a cena
function scene:create(event)
    local sceneGroup = self.view

    -- Adicionar física ao projeto
    physics.start()
    physics.setGravity(0, 9.8)

    -- Criar o cenário
    createBackground(sceneGroup)

    -- Criar o solo
    createGround(sceneGroup)

    -- Botões de navegação
    local Avancar = display.newImageRect(sceneGroup, "Assets/imagens/botaoProximo.png", 141, 50)
    Avancar.x = display.contentCenterX + 300
    Avancar.y = display.contentHeight - 100
    Avancar:addEventListener("tap", function()
        composer.gotoScene("ContraCapa", {
            effect = "fromRight",
            time = 1000
        })
    end)

    local Voltar = display.newImageRect(sceneGroup, "Assets/imagens/botaoAnterior.png", 141, 50)
    Voltar.x = display.contentCenterX - 300
    Voltar.y = display.contentHeight - 100
    Voltar:addEventListener("tap", function()
        composer.gotoScene("Page04", {
            effect = "fromLeft",
            time = 1000
        })
    end)

    local button = display.newImageRect(sceneGroup, "Assets/imagens/off.png", 60, 60)
    button.x = 70
    button.y = 60

    if not somPag5 then
        somPag5 = audio.loadSound("Assets/audios/audioPagina5.mp3")
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
            somChannel = audio.play(somPag5, {
                loops = -1
            })
        end
    end
    button:addEventListener("tap", toggleSound)
end

-- show()
function scene:show(event)
    local phase = event.phase

    if (phase == "did") then
        -- Adicionar evento de toque ao entrar na página 5
        if not touchListenerAdded then
            Runtime:addEventListener("touch", launchSeed)
            touchListenerAdded = true
        end

        -- Tocar som se estiver ligado
        if somLigado then
            somChannel = audio.play(somPag5, {
                loops = -1
            })
        end
    end
end

-- hide()
function scene:hide(event)
    local phase = event.phase

    if (phase == "will") then
        -- Remover evento de toque ao sair da página 5
        if touchListenerAdded then
            Runtime:removeEventListener("touch", launchSeed)
            touchListenerAdded = false
        end

        -- Pausar som ao sair da página
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
    if somPag5 then
        audio.dispose(somPag5)
    end
    physics.stop()
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
