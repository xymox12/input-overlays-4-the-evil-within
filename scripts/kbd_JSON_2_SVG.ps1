$jsonPath = "./keyboard.json"
$jsonData = Get-Content $jsonPath | ConvertFrom-Json

# Define a key map for common keys
$keyMap = @{
    32 = "Space"; 49 = "1"; 50 = "2"; 51 = "3"; 52 = "4";
    65 = "A"; 68 = "D"; 69 = "E"; 70 = "F"; 81 = "Q";
    82 = "R"; 83 = "S"; 86 = "V"; 87 = "W"; 160 = "Shift";
    162 = "Ctrl"; 27 = "Esc"; 3 = "Mouse Button"; 0 = "Mouse Scroll Up";
    1 = "Mouse Scroll Down"; 4 = "Mouse Button"
}

# Calculate required height for table
$tableRows = $jsonData.Elements.Count + 2  # Extra rows for headers
$rowHeight = 15
$extraHeight = $tableRows * $rowHeight + 20
$totalHeight = $jsonData.Height + $extraHeight

# Define SVG header with increased height
$svgHeader = "<svg xmlns='http://www.w3.org/2000/svg' width='$($jsonData.Width)' height='$totalHeight' viewBox='0 0 $($jsonData.Width) $totalHeight'>"
$svgContent = ""
$dimensionsTable = ""

$yOffset = $jsonData.Height + 20 # Start table below keyboard
$colWidth = 50

# Table headers
$headers = @("ID", "Width", "Height", "X1,Y1", "X2,Y2", "X3,Y3", "X4,Y4", "Key")
$xPos = 10
foreach ($header in $headers) {
    $dimensionsTable += "<text x='$xPos' y='$yOffset' font-size='12' font-weight='bold'>$header</text>"
    $xPos += $colWidth
}
$yOffset += $rowHeight

foreach ($element in $jsonData.Elements) {
    $id = $element.Id
    $boundaries = $element.Boundaries
    
    # Extract key text from KeyCodes
    $keyText = "Unknown"
    if ($element.KeyCodes.Count -gt 0) {
        $keyCode = $element.KeyCodes[0]
        if ($keyMap.ContainsKey($keyCode)) {
            $keyText = $keyMap[$keyCode]
        } else {
            $keyText = "KeyCode $keyCode"
        }
    }
    
    # Extract coordinates
    $xMin = ($boundaries | Sort-Object X | Select-Object -First 1).X
    $yMin = ($boundaries | Sort-Object Y | Select-Object -First 1).Y
    $xMax = ($boundaries | Sort-Object X | Select-Object -Last 1).X
    $yMax = ($boundaries | Sort-Object Y | Select-Object -Last 1).Y
    
    # Calculate width and height
    $width = $xMax - $xMin
    $height = $yMax - $yMin
    
    # Get corner coordinates
    $corner1 = "$($boundaries[0].X),$($boundaries[0].Y)"
    $corner2 = "$($boundaries[1].X),$($boundaries[1].Y)"
    $corner3 = "$($boundaries[2].X),$($boundaries[2].Y)"
    $corner4 = "$($boundaries[3].X),$($boundaries[3].Y)"
    
    # Generate rectangle element for key with tooltip
    $svgContent += "<g>
        <rect x='$xMin' y='$yMin' width='$width' height='$height' fill='lightgray' stroke='black'>
            <title>ID: $id - Key: $keyText</title>
        </rect>
    </g>"
    
    # Add entry to table
    $xPos = 10
    $dataValues = @($id, $width, $height, $corner1, $corner2, $corner3, $corner4, $keyText)
    foreach ($value in $dataValues) {
        $dimensionsTable += "<text x='$xPos' y='$yOffset' font-size='10'>$value</text>"
        $xPos += $colWidth
    }
    $yOffset += $rowHeight
}

# Close SVG tag
$svgFooter = "</svg>"

# Write to SVG file
$svgFilePath = "./keyboard_layout.svg"
$svgOutput = $svgHeader + $svgContent + $dimensionsTable + $svgFooter
$svgOutput | Out-File -Encoding utf8 $svgFilePath

Write-Host "SVG file generated at $svgFilePath"
