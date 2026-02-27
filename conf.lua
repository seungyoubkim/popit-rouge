function love.conf(t)
    t.title = "Popit Rouge"
    t.version = "11.4"

    -- 기본 윈도우 설정 (세로 모바일 기준 9:16 비율)
    t.window.width = 450
    t.window.height = 800
    t.window.resizable = true

    -- 모바일 설정
    t.window.fullscreen = false
    t.window.vsync = 1

    -- 사용하지 않는 모듈 비활성화
    t.modules.joystick = false
    t.modules.physics = false
end
