# Load JSON data
$jsonFile = "keyboard_layout.json"  # Replace with your JSON file path
$jsonData = Get-Content $jsonFile | ConvertFrom-Json

# Extract overlay dimensions
$overlayWidth = $jsonData.overlay_width
$overlayHeight = $jsonData.overlay_height

# Define SVG header
$svgHeader = @"
<svg xmlns="http://www.w3.org/2000/svg" width="$overlayWidth" height="$overlayHeight" viewBox="0 0 $overlayWidth $overlayHeight">
    <style>
        .keyboard-key {
            fill: lightgrey;
            stroke: none;
        }
        .background {
            fill: black;
        }
    </style>
    <rect class="background" width="$overlayWidth" height="$overlayHeight" />
"@

# Initialize SVG body
$svgBody = ""

# Iterate through elements and generate rectangles for keys
foreach ($element in $jsonData.elements) {
    if ($element.type -eq 1) {  # Ensure we process only type 1 elements
        $x = $element.pos[0]  # Use pos x-coordinate for app view placement
        $y = $element.pos[1]  # Use pos y-coordinate for app view placement
        $width = $element.mapping[2]  # Use mapping width
        $height = $element.mapping[3]  # Use mapping height
        $id = $element.id
        $code = $element.code
        $zLevel = $element.z_level
        $mappingX = $element.mapping[0]
        $mappingY = $element.mapping[1]
        $type = $element.type

        # Append rectangle to SVG body with additional data
        $svgBody += @"
    <rect id="$id" class="keyboard-key" x="$x" y="$y" width="$width" height="$height" 
          data-code="$code" data-z-level="$zLevel" data-mapping-x="$mappingX" data-mapping-y="$mappingY" 
          data-mapping-width="$width" data-mapping-height="$height" data-type="$type">
        <title>$id</title>
    </rect>
"@
    }
}

# Define SVG footer
$svgFooter = "</svg>"

# Combine all parts and output to file
$svgContent = $svgHeader + $svgBody + $svgFooter

$svgFile = "keyboard_layout.svg"  # Replace with your desired output file
$svgContent | Out-File -Encoding utf8 $svgFile

Write-Host "SVG file generated: $svgFile"