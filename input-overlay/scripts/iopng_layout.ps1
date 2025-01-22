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

# Iterate through elements and generate rectangles for keys using mapping positions
foreach ($element in $jsonData.elements) {
    if ($element.type -eq 1) {  # Ensure we process only type 1 elements
        $x = $element.mapping[0]  # Use mapping x-coordinate for PNG layout placement
        $y = $element.mapping[1]  # Use mapping y-coordinate for PNG layout placement
        $width = $element.mapping[2]  # Use mapping width
        $height = $element.mapping[3]  # Use mapping height
        $id = $element.id
        $code = $element.code
        $zLevel = $element.z_level
        $type = $element.type

        # Append rectangle to SVG body with additional data
        $svgBody += @"
    <rect id="$id" class="keyboard-key" x="$x" y="$y" width="$width" height="$height" 
          data-code="$code" data-z-level="$zLevel" data-mapping-x="$x" data-mapping-y="$y" 
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

$svgFile = "keyboard_bitmap_layout.svg"  # Output file representing PNG layout
$svgContent | Out-File -Encoding utf8 $svgFile

Write-Host "SVG file representing PNG layout generated: $svgFile"
