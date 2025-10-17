#!/bin/bash

echo "🔍 Tipob Implementation Verification"
echo "===================================="
echo ""

echo "✅ Checking modified files exist..."
files=(
    "Tipob/Models/GameModel.swift"
    "Tipob/Models/GestureType.swift"
    "Tipob/ViewModels/GameViewModel.swift"
    "Tipob/Utilities/SwipeGestureModifier.swift"
    "Tipob/Utilities/UnifiedGestureModifier.swift"
    "Tipob/Components/ArrowView.swift"
    "Tipob/Views/GamePlayView.swift"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ MISSING: $file"
    fi
done

echo ""
echo "🔍 Checking code changes..."

echo "  Checking GestureType.swift for new gestures..."
if grep -q "case tap" Tipob/Models/GestureType.swift; then
    echo "    ✓ 'tap' gesture found"
else
    echo "    ✗ 'tap' gesture NOT found"
fi

if grep -q "case doubleTap" Tipob/Models/GestureType.swift; then
    echo "    ✓ 'doubleTap' gesture found"
else
    echo "    ✗ 'doubleTap' gesture NOT found"
fi

if grep -q "case longPress" Tipob/Models/GestureType.swift; then
    echo "    ✓ 'longPress' gesture found"
else
    echo "    ✗ 'longPress' gesture NOT found"
fi

if grep -q "case twoFingerSwipe" Tipob/Models/GestureType.swift; then
    echo "    ✓ 'twoFingerSwipe' gesture found"
else
    echo "    ✗ 'twoFingerSwipe' gesture NOT found"
fi

echo ""
echo "  Checking GamePlayView.swift uses new gesture modifier..."
if grep -q "detectGestures" Tipob/Views/GamePlayView.swift; then
    echo "    ✓ 'detectGestures' modifier found"
else
    echo "    ✗ Still using old 'detectSwipes' modifier"
fi

echo ""
echo "  Checking UnifiedGestureModifier.swift exists and has content..."
if [ -f "Tipob/Utilities/UnifiedGestureModifier.swift" ]; then
    lines=$(wc -l < "Tipob/Utilities/UnifiedGestureModifier.swift")
    echo "    ✓ File exists ($lines lines)"

    if grep -q "struct UnifiedGestureModifier" Tipob/Utilities/UnifiedGestureModifier.swift; then
        echo "    ✓ UnifiedGestureModifier struct defined"
    fi

    if grep -q "func detectGestures" Tipob/Utilities/UnifiedGestureModifier.swift; then
        echo "    ✓ detectGestures extension found"
    fi
else
    echo "    ✗ UnifiedGestureModifier.swift NOT found"
fi

echo ""
echo "⚠️  Checking if file is in Xcode project..."
if grep -q "UnifiedGestureModifier.swift" Tipob.xcodeproj/project.pbxproj 2>/dev/null; then
    echo "    ✓ UnifiedGestureModifier.swift IS in Xcode project"
else
    echo "    ✗ UnifiedGestureModifier.swift NOT in Xcode project"
    echo ""
    echo "    🔧 ACTION REQUIRED:"
    echo "    You need to add UnifiedGestureModifier.swift to your Xcode project:"
    echo "    1. Open Xcode"
    echo "    2. Right-click 'Utilities' folder in Project Navigator"
    echo "    3. Select 'Add Files to Tipob...'"
    echo "    4. Select 'Tipob/Utilities/UnifiedGestureModifier.swift'"
    echo "    5. Ensure 'Add to targets: Tipob' is checked"
    echo "    6. Click 'Add'"
    echo "    7. Clean Build (Cmd+Shift+K) and Rebuild (Cmd+B)"
fi

echo ""
echo "📊 Summary:"
total_gestures=$(grep -c "^    case " Tipob/Models/GestureType.swift)
echo "  Total gesture cases in GestureType.swift: $total_gestures"

if [ "$total_gestures" -eq 8 ]; then
    echo "  ✓ Expected 8 gestures - CORRECT!"
else
    echo "  ✗ Expected 8 gestures, found $total_gestures"
fi

echo ""
echo "===================================="
echo "Verification complete!"
