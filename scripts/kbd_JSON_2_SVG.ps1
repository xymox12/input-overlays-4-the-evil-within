# Load the JSON file
$jsonPath = "keyboard.json"
$jsonData = Get-Content $jsonPath | ConvertFrom-Json

# Start the SVG output
$svgOutput = @"
<svg width='$($jsonData.Width)' height='$($jsonData.Height)' xmlns='http://www.w3.org/2000/svg'>
"@

# Iterate through elements in JSON
foreach ($element in $jsonData.Elements) {
    $type = $element.PSObject.Properties["__type"].Value
    switch ($type) {
        KeyboardKey {
            $x = $element.Boundaries[0].X
            $y = $element.Boundaries[0].Y
            $width = $element.Boundaries[1].X - $element.Boundaries[0].X
            $height = $element.Boundaries[2].Y - $element.Boundaries[1].Y
            $svgOutput += "<rect x='$x' y='$y' width='$width' height='$height' stroke='black' fill='white'/>`n"
        }
        MouseKey {
            $x = $element.Boundaries[0].X
            $y = $element.Boundaries[0].Y
            $width = $element.Boundaries[1].X - $element.Boundaries[0].X
            $height = $element.Boundaries[2].Y - $element.Boundaries[1].Y
            $svgOutput += "<rect x='$x' y='$y' width='$width' height='$height' stroke='blue' fill='lightgrey'/>`n"
        }
        MouseScroll {
            $x = $element.Boundaries[0].X
            $y = $element.Boundaries[0].Y
            $width = $element.Boundaries[1].X - $element.Boundaries[0].X
            $height = $element.Boundaries[2].Y - $element.Boundaries[1].Y
            $svgOutput += "<rect x='$x' y='$y' width='$width' height='$height' stroke='green' fill='lightgrey'/>`n"
        }
        MouseSpeedIndicator {
            $cx = $element.Location.X
            $cy = $element.Location.Y
            $r = $element.Radius
            $svgOutput += "<circle cx='$cx' cy='$cy' r='$r' stroke='red' fill='none' stroke-width='2'/>`n"
        }
    }
}

# Close the SVG output
$svgOutput += "</svg>"

# Save to file
$svgOutput | Out-File -Encoding utf8 "keyboard_layout.svg"

Write-Output "SVG file generated: keyboard_layout.svg"
