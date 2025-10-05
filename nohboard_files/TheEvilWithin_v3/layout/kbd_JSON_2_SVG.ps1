# Load the JSON file
$jsonPath = "keyboard.json"
$jsonData = Get-Content $jsonPath | ConvertFrom-Json

# Create a mapping of key codes to key names
$keyMap = @{}

# Populate the mapping using the [System.ConsoleKey] enumeration
foreach ($keyName in [Enum]::GetNames([System.ConsoleKey])) {
    $keyCode = [int][System.ConsoleKey]::$keyName
    $keyMap[$keyCode] = $keyName
}
# Add extended modifier keys to the key map
$extendedModifierKeys = @{
    16  = 'Shift'
    17  = 'Control'
    18  = 'Alt'
    160 = 'LeftShift'
    161 = 'RightShift'
    162 = 'LeftCtrl'
    163 = 'RightCtrl'
    164 = 'LeftAlt'
    165 = 'RightAlt'
}

foreach ($code in $extendedModifierKeys.Keys) {
    $keyMap[$code] = $extendedModifierKeys[$code]
}

function Get-KeyName {
    param(
        [int]$keyCode
    )

    if ($keyMap.ContainsKey($keyCode)) {
        return $keyMap[$keyCode]
    } elseif ($keyCode -ge 0 -and $keyCode -le 0x10FFFF) {
        # Attempt to convert to a Unicode character
        $char = [char]$keyCode
        if ([char]::IsControl($char)) {
            return "Control Character (code $keyCode)"
        } else {
            return $char
        }
    } else {
        return "Invalid key code"
    }
}

$mouseKeyCodes = @{
		0 = 'Mouse Left Button'
		1 = "Mouse Right Button"
		3 = "Mouse Button 1"
		4 = "Mouse Button 2"
}

$mouseScrollCodes = @{
	 0 = 'Up'
	 1 = 'Down'
	 2 = 'Right'
	 3 = 'Left'
}

# Start the SVG output
$svgOutput = @"
<svg width='$($jsonData.Width)' height='$($jsonData.Height)' xmlns='http://www.w3.org/2000/svg'>
    <style>
        .keyboard-key { fill: grey; stroke: black; stroke-width: 1; opacity: 0.5; }
        .mouse-key { fill: lightgrey; stroke: blue; stroke-width: 1; }
        .mouse-scroll { fill: lightgrey; stroke: green; stroke-width: 1; }
        .mouse-speed { fill: #EEE; stroke: red; stroke-width: 2; }
    </style>
"@

# Iterate through elements in JSON
foreach ($element in $jsonData.Elements) {
    $id = $element.Id
    switch ($element.__type) {
        KeyboardKey {
            $character = Get-KeyName -keyCode $element.keyCodes[0]
            $x = $element.Boundaries[0].X
            $y = $element.Boundaries[0].Y
            $width = $element.Boundaries[1].X - $element.Boundaries[0].X
            $height = $element.Boundaries[2].Y - $element.Boundaries[1].Y
            $svgOutput += "<rect id='$id' class='keyboard-key' x='$x' y='$y' width='$width' height='$height'>`n"
            $svgOutput += "<title>ID:$id; Key: $character</title>`n"
            $svgOutput += "</rect>`n"
        }
        MouseKey {
			$kc = [int]$element.keyCodes[0]
            $x = $element.Boundaries[0].X
            $y = $element.Boundaries[0].Y
            $width = $element.Boundaries[1].X - $element.Boundaries[0].X
            $height = $element.Boundaries[2].Y - $element.Boundaries[1].Y
            $svgOutput += "<rect id='$id' class='mouse-key' x='$x' y='$y' width='$width' height='$height'>`n"
			$svgOutput += "<title>ID:$id; Key: $($mouseKeyCodes[$kc])</title>`n"
			$svgOutput += "</rect>`n"
        }
        MouseScroll {
			# Assuming $element.keyCodes[0] exists and contains a valid key code
			$kc = [int]$element.keyCodes[0]
			$x = $element.Boundaries[0].X
			$y = $element.Boundaries[0].Y
			$width = $element.Boundaries[1].X - $element.Boundaries[0].X
			$height = $element.Boundaries[2].Y - $element.Boundaries[1].Y
			$svgOutput += "<rect id='$id' class='mouse-scroll' x='$x' y='$y' width='$width' height='$height'>`n"
			$svgOutput += "<title>ID:$id; Key: $($mouseScrollCodes[$kc])</title>`n"
			$svgOutput += "</rect>`n"
        }
        MouseSpeedIndicator {
            $cx = $element.Location.X
            $cy = $element.Location.Y
            $r = $element.Radius
            $svgOutput += "<circle id='$id' class='mouse-speed' cx='$cx' cy='$cy' r='$r'>`n"
			$svgOutput += "<title>ID:$id; Mouse Direction/Speed</title>`n"
			$svgOutput += "</circle>`n"
        }
    }
}

# Close the SVG output
$svgOutput += "</svg>"

# Save to file
$svgOutput | Out-File -Encoding utf8 "keyboard_layout.svg"

Write-Output "SVG file generated: keyboard_layout.svg"

