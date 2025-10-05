; Define the target window. Change "YourWindowTitle" to the specific window you want.
targetWindow := "TEW"  

; Check if the window exists. If not, show a message and exit.
if !WinExist(targetWindow) {
    MsgBox, 48, Error, Window not found!
    ExitApp
}

; Call the function on the specific window with the transparency value (default 177).
Montage(targetWindow, 177)
ExitApp

Montage(target, trans := 177) {
    ; Get the current extended window style for the target.
    WinGet, ExStyle, ExStyle, %target%
    
    ; Check if the window already has layered, transparent, and topmost styles.
    if (ExStyle & 0x80028) == 0x80028 {
        ; Remove always-on-top.
        WinSet, AlwaysOnTop, Off, %target%
        ; Remove the combined extended styles.
        WinSet, ExStyle, -0x80028, %target%
        ; Restore the typical window style.
        WinSet, Style, +0xC40000, %target%
    } else {
        ; Set the window to always be on top.
        WinSet, AlwaysOnTop, On, %target%
        ; Remove the default window style.
        WinSet, Style, -0xC40000, %target%
        ; Move the window to a fixed position.
        WinMove, %target%, , , , , 580, 280
        ; Remove the menu from the window.
        DllCall("SetMenu", "Ptr", WinExist(target), "Ptr", 0)
        ; Apply layered, transparent, and topmost styles.
        WinSet, ExStyle, +0x80028, %target%
        ; Set a transparency color key (black) with the provided transparency threshold.
        WinSet, Transcolor, 000000 %trans%, %target%
    }
}
