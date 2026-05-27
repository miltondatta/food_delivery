Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outDir = Join-Path $root "architecture"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$W = 1920
$H = 1080

function New-Brush($hex) {
    return New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($hex))
}

function New-Pen($hex, $width = 2) {
    $pen = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml($hex), $width)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    return $pen
}

function New-Font($size, $style = [System.Drawing.FontStyle]::Regular) {
    return New-Object System.Drawing.Font("Segoe UI", $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

function New-RectPath($x, $y, $w, $h, $r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function Draw-RoundedBox($g, $x, $y, $w, $h, $r, $fill, $stroke, $strokeWidth = 2) {
    $path = New-RectPath $x $y $w $h $r
    $g.FillPath((New-Brush $fill), $path)
    if ($stroke) {
        $g.DrawPath((New-Pen $stroke $strokeWidth), $path)
    }
    $path.Dispose()
}

function Draw-TextBlock($g, $text, $x, $y, $w, $h, $font, $color = "#17202A", $align = "Near", $valign = "Near") {
    $fmt = New-Object System.Drawing.StringFormat
    $fmt.Alignment = [System.Drawing.StringAlignment]::$align
    $fmt.LineAlignment = [System.Drawing.StringAlignment]::$valign
    $fmt.Trimming = [System.Drawing.StringTrimming]::None
    $fmt.FormatFlags = 0
    $rect = New-Object System.Drawing.RectangleF($x, $y, $w, $h)
    $g.DrawString($text, $font, (New-Brush $color), $rect, $fmt)
    $fmt.Dispose()
}

function Draw-Label($g, $text, $x, $y, $w, $h, $fill, $stroke, $titleColor = "#17202A", $subColor = "#405161") {
    Draw-RoundedBox $g $x $y $w $h 20 $fill $stroke 2
    $parts = $text -split "`n", 2
    Draw-TextBlock $g $parts[0] ($x + 22) ($y + 13) ($w - 44) 32 (New-Font 22 ([System.Drawing.FontStyle]::Bold)) $titleColor "Near" "Near"
    if ($parts.Count -gt 1) {
        Draw-TextBlock $g $parts[1] ($x + 22) ($y + 47) ($w - 44) ($h - 58) (New-Font 17) $subColor "Near" "Near"
    }
}

function Draw-Pill($g, $text, $x, $y, $w, $fill, $stroke = $null) {
    Draw-RoundedBox $g $x $y $w 42 21 $fill $stroke 1.5
    Draw-TextBlock $g $text $x ($y + 2) $w 38 (New-Font 19 ([System.Drawing.FontStyle]::Bold)) "#20303D" "Center" "Center"
}

function Draw-Arrow($g, $x1, $y1, $x2, $y2, $color = "#44546A", $width = 4) {
    $pen = New-Pen $color $width
    $pen.CustomEndCap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(7, 9)
    $g.DrawLine($pen, $x1, $y1, $x2, $y2)
    $pen.Dispose()
}

function Draw-Canvas($path, [scriptblock]$draw) {
    $bmp = New-Object System.Drawing.Bitmap($W, $H)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $g.Clear([System.Drawing.ColorTranslator]::FromHtml("#F7F8FA"))
    & $draw $g
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

$navy = "#17202A"
$muted = "#5B6673"
$line = "#C7D0D9"
$green = "#DDF5E7"
$greenLine = "#50B878"
$blue = "#DDEBFF"
$blueLine = "#4C8DFF"
$amber = "#FFF1D6"
$amberLine = "#E0A12E"
$rose = "#FFE4E1"
$roseLine = "#E35D6A"
$teal = "#DDF6F3"
$tealLine = "#37A99C"
$lav = "#EEE7FF"
$lavLine = "#8C6BE8"
$gray = "#EEF1F4"
$grayLine = "#A9B3BE"

Draw-Canvas (Join-Path $outDir "luick-visual-architecture.png") {
    param($g)

    Draw-TextBlock $g "luick" 72 40 220 64 (New-Font 54 ([System.Drawing.FontStyle]::Bold)) "#141A20"
    Draw-TextBlock $g "Visual architecture for a user-friendly professional food delivery mobile app" 292 55 1100 42 (New-Font 26) $muted
    Draw-Pill $g "Mobile v1 scope" 1558 48 250 "#E7F8ED" "#56B870"

    Draw-RoundedBox $g 70 132 1780 140 24 "#FFFFFF" $line 2
    Draw-TextBlock $g "Supporting delivery workflow" 100 154 420 32 (New-Font 25 ([System.Drawing.FontStyle]::Bold)) $navy

    $wfY = 190
    $wf = @(
        "Codex workflow",
        "Google Stitch handoff",
        "Flutter Native app",
        "Android Simulator`nverification"
    )
    $wfX = @(100, 535, 970, 1405)
    for ($i = 0; $i -lt $wf.Count; $i++) {
        Draw-Label $g $wf[$i] $wfX[$i] $wfY 350 72 "#F7FBFF" $blueLine
        if ($i -lt 3) {
            Draw-Arrow $g ($wfX[$i] + 360) ($wfY + 26) ($wfX[$i + 1] - 18) ($wfY + 26) "#7890AA" 3
        }
    }

    Draw-RoundedBox $g 70 290 1780 610 28 "#FFFFFF" $line 2
    Draw-TextBlock $g "Customer app flow" 100 316 410 36 (New-Font 28 ([System.Drawing.FontStyle]::Bold)) $navy
    Draw-TextBlock $g "Single customer journey: discover food, customize items, place a mock order, and follow status." 408 320 1040 34 (New-Font 21) $muted

    $screenW = 260
    $screenH = 88
    $gap = 34
    $startX = 110
    $row1Y = 370
    $row2Y = 510
    $row3Y = 650

    $screens1 = @(
        @("Browse restaurants", "Cuisine, distance, offers"),
        @("Search / filter", "Keyword, cuisine, price"),
        @("Restaurant detail", "Hero, hours, fees"),
        @("Menu items", "Details, modifiers, quantity"),
        @("Cart", "Items, totals, edit")
    )
    for ($i = 0; $i -lt $screens1.Count; $i++) {
        $x = $startX + ($screenW + $gap) * $i
        Draw-Label $g ($screens1[$i][0] + "`n" + $screens1[$i][1]) $x $row1Y $screenW $screenH $green $greenLine
        if ($i -lt $screens1.Count - 1) { Draw-Arrow $g ($x + $screenW + 8) ($row1Y + 44) ($x + $screenW + $gap - 8) ($row1Y + 44) "#5FAE7A" 3 }
    }

    Draw-Arrow $g 1482 462 1482 510 "#5FAE7A" 3
    $screens2 = @(
        @("Checkout", "Contact, address, notes"),
        @("Saved addresses", "Home, work, recent"),
        @("Delivery instructions", "Dropoff note, phone"),
        @("Order confirmation", "Summary, expected time")
    )
    for ($i = 0; $i -lt $screens2.Count; $i++) {
        $x = 1228 - ($screenW + $gap) * $i
        Draw-Label $g ($screens2[$i][0] + "`n" + $screens2[$i][1]) $x $row2Y $screenW $screenH $amber $amberLine
        if ($i -lt $screens2.Count - 1) { Draw-Arrow $g ($x - 8) ($row2Y + 44) ($x - $gap + 8) ($row2Y + 44) "#D5A03D" 3 }
    }

    Draw-Arrow $g 154 598 154 650 "#D5A03D" 3
    $screens3 = @(
        @("Order tracking", "Status timeline, ETA"),
        @("Order history", "Past orders, reorder")
    )
    for ($i = 0; $i -lt $screens3.Count; $i++) {
        $x = $startX + ($screenW + $gap) * $i
        Draw-Label $g ($screens3[$i][0] + "`n" + $screens3[$i][1]) $x $row3Y $screenW $screenH $teal $tealLine
        if ($i -lt $screens3.Count - 1) { Draw-Arrow $g ($x + $screenW + 8) ($row3Y + 44) ($x + $screenW + $gap - 8) ($row3Y + 44) "#46AFA4" 3 }
    }

    Draw-RoundedBox $g 1030 650 715 156 22 "#FAFBFC" $grayLine 2
    Draw-TextBlock $g "Runtime architecture" 1060 676 330 32 (New-Font 25 ([System.Drawing.FontStyle]::Bold)) $navy
    Draw-Pill $g "Flutter UI" 1060 725 152 "#DDEBFF" "#4C8DFF"
    Draw-Pill $g "State + routing" 1230 725 182 "#EEE7FF" "#8C6BE8"
    Draw-Pill $g "Supabase client" 1430 725 190 "#DDF6F3" "#37A99C"
    Draw-Arrow $g 1212 746 1228 746 "#7890AA" 2.5
    Draw-Arrow $g 1412 746 1428 746 "#7890AA" 2.5

    Draw-RoundedBox $g 1026 812 350 58 18 "#E7F8ED" $greenLine 2
    Draw-TextBlock $g "Supabase Auth" 1052 825 170 26 (New-Font 22 ([System.Drawing.FontStyle]::Bold)) $navy
    Draw-TextBlock $g "email/phone auth" 1220 828 135 24 (New-Font 17) $muted
    Draw-RoundedBox $g 1394 812 350 58 18 "#EAF0FF" $blueLine 2
    Draw-TextBlock $g "Supabase Data" 1420 825 170 26 (New-Font 22 ([System.Drawing.FontStyle]::Bold)) $navy
    Draw-TextBlock $g "orders, menus" 1588 828 135 24 (New-Font 17) $muted

    Draw-RoundedBox $g 70 932 1780 92 24 "#FFF8F7" $roseLine 2
    Draw-TextBlock $g "Guardrails excluded" 100 956 300 30 (New-Font 25 ([System.Drawing.FontStyle]::Bold)) "#8A2430"
    Draw-TextBlock $g "web deployment, restaurant admin, driver dispatch, real payments, refunds, support, reviews, subscriptions, maps, and production marketplace operations" 400 958 1370 36 (New-Font 18) "#763640"
}

Draw-Canvas (Join-Path $outDir "luick-entity-architecture.png") {
    param($g)

    Draw-TextBlock $g "luick" 72 40 220 64 (New-Font 54 ([System.Drawing.FontStyle]::Bold)) "#141A20"
    Draw-TextBlock $g "Entity architecture for the minimum v1 Supabase data model" 292 55 1020 42 (New-Font 26) $muted
    Draw-Pill $g "Postgres + Auth" 1568 48 245 "#E7F8ED" "#56B870"

    Draw-RoundedBox $g 70 132 1780 815 28 "#FFFFFF" $line 2

    function Draw-Entity($g, $name, $fields, $x, $y, $w, $h, $fill, $stroke) {
        Draw-RoundedBox $g $x $y $w $h 22 $fill $stroke 2
        Draw-TextBlock $g $name ($x + 20) ($y + 14) ($w - 40) 32 (New-Font 24 ([System.Drawing.FontStyle]::Bold)) "#17202A"
        $body = ($fields -join "`n")
        Draw-TextBlock $g $body ($x + 20) ($y + 56) ($w - 40) ($h - 64) (New-Font 16) "#384858"
    }

    $entities = @{
        "User / Profile" = @{ x = 110; y = 185; w = 310; h = 150; fill = $blue; stroke = $blueLine; fields = @("id: uuid, auth_user_id", "name, phone, avatar_url", "created_at, updated_at") }
        Address = @{ x = 110; y = 405; w = 310; h = 160; fill = $teal; stroke = $tealLine; fields = @("id, user_id", "label, line1, area, city", "instructions, is_default", "lat_lng optional placeholder") }
        Cart = @{ x = 110; y = 635; w = 310; h = 150; fill = $amber; stroke = $amberLine; fields = @("id, user_id, restaurant_id", "address_id nullable", "subtotal, fees_estimate", "status: active | converted") }

        Restaurant = @{ x = 545; y = 185; w = 330; h = 165; fill = $green; stroke = $greenLine; fields = @("id, name, cuisine_tags", "image_url, rating_display", "delivery_fee_estimate", "is_open, eta_range") }
        MenuItem = @{ x = 545; y = 430; w = 330; h = 165; fill = $lav; stroke = $lavLine; fields = @("id, restaurant_id", "name, description, image_url", "base_price, category", "is_available") }
        MenuModifier = @{ x = 545; y = 690; w = 330; h = 165; fill = "#F3E9FF"; stroke = "#A773E8"; fields = @("id, menu_item_id", "name, type", "min_select, max_select", "options JSON, price_delta") }

        CartItem = @{ x = 1010; y = 520; w = 330; h = 165; fill = "#FFF5DE"; stroke = "#E0A12E"; fields = @("id, cart_id, menu_item_id", "quantity, unit_price", "selected_modifiers JSON", "special_note") }
        Order = @{ x = 1465; y = 215; w = 330; h = 190; fill = "#EAF0FF"; stroke = "#4C8DFF"; fields = @("id, user_id, restaurant_id", "address_id, cart_snapshot", "status, totals", "delivery_instructions", "placed_at") }
        OrderItem = @{ x = 1465; y = 495; w = 330; h = 165; fill = "#FFEDE8"; stroke = "#E35D6A"; fields = @("id, order_id, menu_item_id", "name_snapshot, quantity", "unit_price, modifiers_snapshot", "line_total") }
        OrderStatusEvent = @{ x = 1465; y = 750; w = 330; h = 150; fill = "#E7F8ED"; stroke = "#50B878"; fields = @("id, order_id", "status, message", "created_at", "actor: system") }
    }

    foreach ($key in @("User / Profile","Address","Cart","Restaurant","MenuItem","MenuModifier","CartItem","Order","OrderItem","OrderStatusEvent")) {
        $e = $entities[$key]
        Draw-Entity $g $key $e["fields"] $e["x"] $e["y"] $e["w"] $e["h"] $e["fill"] $e["stroke"]
    }

    function Center($e, $side) {
        $x = [float]$e["x"]
        $y = [float]$e["y"]
        $w = [float]$e["w"]
        $h = [float]$e["h"]
        switch ($side) {
            "R" { return @(($x + $w), ($y + ($h / 2))) }
            "L" { return @($x, ($y + ($h / 2))) }
            "T" { return @(($x + ($w / 2)), $y) }
            "B" { return @(($x + ($w / 2)), ($y + $h)) }
        }
    }
    function Rel($from, $fromSide, $to, $toSide, $label, $labelX, $labelY) {
        $a = Center $entities[$from] $fromSide
        $b = Center $entities[$to] $toSide
        Draw-Arrow $g $a[0] $a[1] $b[0] $b[1] "#5F6F7F" 3
        Draw-RoundedBox $g $labelX $labelY 120 34 17 "#FFFFFF" "#D4DAE1" 1
        Draw-TextBlock $g $label $labelX ($labelY + 2) 120 30 (New-Font 16 ([System.Drawing.FontStyle]::Bold)) "#405161" "Center" "Center"
    }

    Rel "User / Profile" "B" "Address" "T" "1 to many" 205 356
    Rel "Address" "B" "Cart" "T" "selected" 205 585
    Rel "Restaurant" "B" "MenuItem" "T" "has menu" 652 374
    Rel "MenuItem" "B" "MenuModifier" "T" "options" 655 624
    Rel "Cart" "R" "CartItem" "L" "contains" 680 644
    Rel "MenuItem" "R" "CartItem" "L" "chosen item" 890 508
    Rel "Order" "B" "OrderItem" "T" "contains" 1570 426
    Rel "CartItem" "R" "OrderItem" "L" "snapshot" 1350 553
    Rel "OrderItem" "B" "OrderStatusEvent" "T" "status log" 1570 684

    Draw-RoundedBox $g 1010 185 330 170 22 "#FAFBFC" "#A9B3BE" 2
    Draw-TextBlock $g "Data behavior" 1034 208 260 30 (New-Font 23 ([System.Drawing.FontStyle]::Bold)) $navy
    Draw-TextBlock $g "Cart is mutable. Checkout creates an Order snapshot. After confirmation, status changes append OrderStatusEvent rows." 1034 248 270 82 (New-Font 17) $muted

    Draw-RoundedBox $g 70 970 1780 58 22 "#FFF8F7" $roseLine 2
    Draw-TextBlock $g "Out of scope: real payment records, refunds, support tickets, reviews, subscriptions, driver dispatch, map polylines, marketplace ops." 104 986 1710 28 (New-Font 22 ([System.Drawing.FontStyle]::Bold)) "#763640"
}

Write-Host "Generated:"
Write-Host (Join-Path $outDir "luick-visual-architecture.png")
Write-Host (Join-Path $outDir "luick-entity-architecture.png")
