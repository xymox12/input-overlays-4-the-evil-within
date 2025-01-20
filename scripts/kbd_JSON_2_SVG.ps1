# Load the JSON file
$jsonPath = "keyboard.json"
$jsonData = Get-Content $jsonPath | ConvertFrom-Json

# Start the SVG output
$svgOutput = @"
<svg width='$($jsonData.Width)' height='$($jsonData.Height)' xmlns='http://www.w3.org/2000/svg'>
    <style>
        .keyboard-key { fill: grey; stroke: black; stroke-width: 1; opacity: 0.5; }
        .mouse-key { fill: lightgrey; stroke: blue; stroke-width: 1; }
        .mouse-scroll { fill: lightgrey; stroke: green; stroke-width: 1; }
        .mouse-speed { fill: none; stroke: red; stroke-width: 2; }
    </style>
"@

# Iterate through elements in JSON
foreach ($element in $jsonData.Elements) {
    $id = $element.Id
    switch ($element.__type) {
        KeyboardKey {
            $x = $element.Boundaries[0].X
            $y = $element.Boundaries[0].Y
            $width = $element.Boundaries[1].X - $element.Boundaries[0].X
            $height = $element.Boundaries[2].Y - $element.Boundaries[1].Y
            $svgOutput += "<rect class='keyboard-key' x='$x' y='$y' width='$width' height='$height'>`n"
            $svgOutput += "<title>$id</title>`n"
            $svgOutput += "</rect>"
        }
        MouseKey {
            $x = $element.Boundaries[0].X
            $y = $element.Boundaries[0].Y
            $width = $element.Boundaries[1].X - $element.Boundaries[0].X
            $height = $element.Boundaries[2].Y - $element.Boundaries[1].Y
            $svgOutput += "<rect class='mouse-key' x='$x' y='$y' width='$width' height='$height'/>`n"
        }
        MouseScroll {
            $x = $element.Boundaries[0].X
            $y = $element.Boundaries[0].Y
            $width = $element.Boundaries[1].X - $element.Boundaries[0].X
            $height = $element.Boundaries[2].Y - $element.Boundaries[1].Y
            $svgOutput += "<rect class='mouse-scroll' x='$x' y='$y' width='$width' height='$height'/>`n"
        }
        MouseSpeedIndicator {
            $cx = $element.Location.X
            $cy = $element.Location.Y
            $r = $element.Radius
            $svgOutput += "<circle class='mouse-speed' cx='$cx' cy='$cy' r='$r'/>`n"
        }
    }
}

# Close the SVG output
$svgOutput += "</svg>"

# Save to file
$svgOutput | Out-File -Encoding utf8 "keyboard_layout.svg"

Write-Output "SVG file generated: keyboard_layout.svg"
