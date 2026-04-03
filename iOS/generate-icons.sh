#!/bin/bash
# Generate App Icons for TrashTrove
# Requires: ImageMagick (convert) or any SVG-to-PNG tool
#
# The app icon is a treasure chest / garage sale theme:
# - Gold/amber gradient background matching the treasure color palette
# - Simple house/tag silhouette representing garage sales
#
# Usage: ./generate-icons.sh
# Output: PNG files in TrashTrove/Resources/Assets.xcassets/AppIcon.appiconset/

ICON_DIR="TrashTrove/Resources/Assets.xcassets/AppIcon.appiconset"
SVG_FILE="app-icon.svg"

# Create the SVG icon
cat > "$SVG_FILE" << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#df9c4f"/>
      <stop offset="50%" style="stop-color:#c76b23"/>
      <stop offset="100%" style="stop-color:#a5521f"/>
    </linearGradient>
    <linearGradient id="shine" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:rgba(255,255,255,0.3)"/>
      <stop offset="100%" style="stop-color:rgba(255,255,255,0)"/>
    </linearGradient>
  </defs>
  <!-- Background -->
  <rect width="1024" height="1024" rx="224" fill="url(#bg)"/>
  <!-- Shine overlay -->
  <rect width="1024" height="512" rx="224" fill="url(#shine)"/>
  <!-- House/Garage shape -->
  <path d="M512 220 L780 420 L780 760 L580 760 L580 580 L444 580 L444 760 L244 760 L244 420 Z"
        fill="white" opacity="0.95"/>
  <!-- Roof peak accent -->
  <path d="M512 220 L780 420 L760 420 L512 240 L264 420 L244 420 Z"
        fill="#f9eddb" opacity="0.8"/>
  <!-- Price tag -->
  <g transform="translate(620, 300) rotate(15)">
    <rect x="0" y="0" width="120" height="80" rx="8" fill="#22c55e"/>
    <circle cx="20" cy="15" r="8" fill="white" opacity="0.8"/>
    <text x="60" y="55" text-anchor="middle" font-family="Georgia, serif"
          font-size="36" font-weight="bold" fill="white">$</text>
  </g>
  <!-- TT text -->
  <text x="512" y="880" text-anchor="middle" font-family="Georgia, serif"
        font-size="96" font-weight="bold" fill="white" opacity="0.9">TrashTrove</text>
</svg>
SVGEOF

echo "SVG icon created: $SVG_FILE"

# Generate PNG sizes if ImageMagick is available
if command -v convert &> /dev/null; then
  SIZES=(16 32 64 128 256 512 1024)
  for size in "${SIZES[@]}"; do
    convert "$SVG_FILE" -resize "${size}x${size}" "$ICON_DIR/app-icon-${size == 1024 ? '1024' : "mac-${size}"}.png"
  done
  # iOS requires single 1024x1024
  convert "$SVG_FILE" -resize "1024x1024" "$ICON_DIR/app-icon-1024.png"
  echo "PNG icons generated in $ICON_DIR"
else
  echo ""
  echo "ImageMagick not found. To generate PNG icons, either:"
  echo "  1. Install ImageMagick: brew install imagemagick"
  echo "  2. Open $SVG_FILE in a browser and export as PNG at 1024x1024"
  echo "  3. Use an online SVG-to-PNG converter"
  echo ""
  echo "Required PNG files:"
  echo "  - app-icon-1024.png (1024x1024) - iOS App Store & Mac"
  echo "  - app-icon-mac-16.png (16x16)"
  echo "  - app-icon-mac-32.png (32x32)"
  echo "  - app-icon-mac-64.png (64x64)"
  echo "  - app-icon-mac-128.png (128x128)"
  echo "  - app-icon-mac-256.png (256x256)"
  echo "  - app-icon-mac-512.png (512x512)"
fi
