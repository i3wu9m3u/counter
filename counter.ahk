#Requires AutoHotkey v2.0
#SingleInstance Force

global aiGui, ctrlAI, ctrlX, ctrlSlashY
global aiCount := 1
global aiMax := 3

; === INI 読み込みとバリデーション ===
scriptDir := A_ScriptDir
iniFile := scriptDir "\counter.ini"

defaults := Map(
    "x", 0,
    "y", 0,
    "color", "White",
    "big", 24,
    "small", 14,
    "keyToggleMax", "F1",
    "keyIncrement", "F2",
    "keyReset", "F3",
    "keyExit", "Escape"
)

if !FileExist(iniFile) {
    IniWrite defaults["x"], iniFile, "Settings", "x"
    IniWrite defaults["y"], iniFile, "Settings", "y"
    IniWrite defaults["color"], iniFile, "Settings", "color"
    IniWrite defaults["big"], iniFile, "Settings", "big"
    IniWrite defaults["small"], iniFile, "Settings", "small"
    IniWrite defaults["keyToggleMax"], iniFile, "Settings", "keyToggleMax"
    IniWrite defaults["keyIncrement"], iniFile, "Settings", "keyIncrement"
    IniWrite defaults["keyReset"], iniFile, "Settings", "keyReset"
    IniWrite defaults["keyExit"], iniFile, "Settings", "keyExit"
}

; サポートされる色名一覧
validColors := ["Black", "Silver", "Gray", "White", "Maroon", "Red", "Purple", "Fuchsia",
                "Green", "Lime", "Olive", "Yellow", "Navy", "Blue", "Teal", "Aqua"]

for key, defaultValue in defaults {
    value := IniRead(iniFile, "Settings", key, defaultValue)
    if key = "color" {
		if !ArrayContains(validColors, value) {
		    value := defaultValue
		}
    } else if InStr(key, "key") {
        try Hotkey(value, (*) => 0)
        catch {
            value := defaultValue
        }
    }
    defaults[key] := value
}

x := defaults["x"], y := defaults["y"]
color := defaults["color"]
bigSize := defaults["big"], smallSize := defaults["small"]
keyToggleMax := defaults["keyToggleMax"]
keyIncrement := defaults["keyIncrement"]
keyReset := defaults["keyReset"]
keyExit := defaults["keyExit"]

; === GUI作成 ===
CreateGui()

; === ホットキー登録 ===
Hotkey(keyToggleMax, ToggleMax)
Hotkey(keyIncrement, IncrementCount)
Hotkey(keyReset, ResetCount)
Hotkey(keyExit, (*) => ExitApp())

ArrayContains(array, value) {
    for index, item in array {
        if (item = value) {
            return true
        }
    }
    return false
}

; AI カウンターの表示
CreateGui() {
    global aiGui, ctrlAI, ctrlX, ctrlSlashY
    global x, y, color, smallSize, bigSize, aiCount, aiMax

    aiGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 +LastFound", "AI Counter")
    backColor := (color = "Black") ? "White" : "Black"
    aiGui.BackColor := backColor

    ; 小さい文字で「AI:」
    aiGui.SetFont("s" smallSize, "Arial")
    ctrlAI := aiGui.Add("Text", "c" color " BackgroundTrans", "AI: ")

    ; 大きい文字で「X」
    aiGui.SetFont("s" bigSize " Bold", "Arial")
    ctrlX := aiGui.Add("Text", "c" color " BackgroundTrans yp x+0", aiCount)

    ; 小さい文字で「/Y」
    aiGui.SetFont("s" smallSize, "Arial")
    ctrlSlashY := aiGui.Add("Text", "c" color " BackgroundTrans yp x+0", " / " aiMax)

    ; GUI 表示（オートサイズ）
    aiGui.Show("NoActivate x" x " y" y " AutoSize")
    WinSetTransColor(backColor, aiGui.Hwnd)

    ; ── ここから下端合わせ ──
    ctrlX.GetPos(&x1, &y1, &w1, &h1)
    ctrlAI.GetPos(&x2, &y2, &w2, &h2)

    newY := y1 + h1 - h2

    ctrlAI.Move(, newY)
    ctrlSlashY.Move(, newY)
    ; ────────────────
}

; === GUI更新 ===
UpdateAiText() {
    global ctrlX, ctrlSlashY, aiCount, aiMax
    ctrlX.Value := aiCount
    ctrlSlashY.Value := " / " aiMax
}

; === ホットキー動作 ===
ToggleMax(*) {
    global aiMax, aiCount
    aiMax := (aiMax = 2) ? 3 : 2
    aiCount := 1
    UpdateAiText()
}

IncrementCount(*) {
    global aiCount, aiMax
    aiCount += 1
    if aiCount > aiMax {
        aiCount := 1
    }
    UpdateAiText()
}

ResetCount(*) {
    global aiCount
    aiCount := 1
    UpdateAiText()
}
