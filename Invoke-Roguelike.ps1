Clear-Host

Class Position {
    [object]$x
    [object]$y
    Position() {
        $this.x = @{x = 0}
        $this.y = @{y = 0}
    }
}

class Player  {
    [string]$Symbol
    [string]$Name
    [int]$Level
    [int]$Experience
    [int]$HealthPoints
    [int]$MaxHealthPoints
    [int]$AttackPower
    [int]$DefensePower
    [object]$Position
    Player() {
        $this.Position = New-Object Position
    }
}

class Monster  {
    [string]$Symbol
    [string]$Name
    [string]$Type
    [int]$Level
    [int]$Experience
    [int]$HealthPoints
    [int]$MaxHealthPoints
    [int]$AttackPower
    [int]$DefensePower
    [object]$Position
    Monster() {
        $this.Type = "Enemy"
        $this.Position = New-Object Position
    }
}

Class Room {
    [int]$PosX   # relative x
    [int]$PosY   # relative y
    [int]$Width  # x
    [int]$Height # y
    [System.Collections.ArrayList]$Space
    [string]$Type
    Room() {
        $WidthMod = 2
        $RoomMax = 30
        $RoomMin = 20
        $w = [math]::Round((Get-Random -Minimum $RoomMin -Maximum $RoomMax)) * $WidthMod
        $h = [math]::Round((Get-Random -Minimum $RoomMin -Maximum $RoomMax))
        If ($w % 2 -gt 0) { $w += 1 }
        If ($h % 2 -gt 0) { $h += 1 }
        $s = [System.Collections.ArrayList]::new()
        For ($r = 0; $r -le $h; $r++) {
            $x = $null
            Switch ($r) {
                 0 { $x = "┌" + ("-"*($w - 2)) + "┐" }
                $h { $x = "└" + ("-"*($w - 2)) + "┘" }
           Default { $x = "│" + (" "*($w - 2)) + "│" }
            }
            $s.Add($x) | Out-Null
        }
        $this.Space = $s
        $this.Width = $w
        $this.Height = $h
        $this.Type = "Normal"
    }
}

function New-RandomRoom {
    $Room = New-Object Room
    Return $Room
}

Function New-Position {
    param (
        [Parameter(Mandatory=$true)]$Object,
        [Parameter(Mandatory=$true)][int]$xMove,
        [Parameter(Mandatory=$true)][int]$yMove
    )
    
    $xMove = $xMove * 2 # Account for cursor height
    $Script:Room.Space[$Object.Position.y] = $Script:Room.Space[$Object.Position.y].Remove($Object.Position.x, $Object.Symbol.Length)
    $Script:Room.Space[$Object.Position.y] = $Script:Room.Space[$Object.Position.y].Insert($Object.Position.x, " "*$Object.Symbol.Length)
    If (($Object.Position.y + $yMove -lt $Script:Room.Height) -and ($Object.Position.y + $yMove -gt 0)) {
        $Object.Position.y += $yMove
    }
    If (($Object.Position.x + $xMove -lt $Script:Room.Width) -and ($Object.Position.x + $xMove -gt 0)) {
        $Object.Position.x += $xMove
    }
    $Script:Room.Space[$Object.Position.y] = $Script:Room.Space[$Object.Position.y].Remove($Object.Position.x, $Object.Symbol.Length)
    $Script:Room.Space[$Object.Position.y] = $Script:Room.Space[$Object.Position.y].Insert($Object.Position.x, $Object.Symbol)

   # Write-Host "NewPosition for: $Object $xMove $yMove"
}

Function Update-State {
    Foreach ($Enemy in $Script:Enemies) {
        New-Position -Object $Enemy -xMove (Get-Random -Minimum -1 -Maximum 2) -yMove (Get-Random -Minimum -1 -Maximum 2)
    }
}

Function Draw-Room {
    $Script:Room.Space
}


Function Update-Draw {
    Draw-Room
    Write-Host "Rooms: $($Script:Room.Count)`tw: $($Script:Room.Width)`th: $($Script:Room.Height)"
    Write-Host "$($Player.Name)`t$($Player.Symbol)`t x:$($Script:Player.Position.x)`ty:$($Script:Player.Position.y)"
    Foreach ($Enemy in $Script:Enemies) {
        Write-Host "$($Enemy.Name)`t$($Enemy.Symbol)`t x:$($Enemy.Position.x)`ty:$($Enemy.Position.y)"
    }
}

Function Get-Input {
    #$Cursor = $Host.UI.RawUI.CursorPosition
    $Key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    switch ($Key.VirtualKeyCode) {
        32 {  } # Space
        37 { New-Position -Object $Script:Player -xMove -1 -yMove 0 } # Left
        38 { New-Position -Object $Script:Player -xMove 0 -yMove -1 } # Up
        39 { New-Position -Object $Script:Player -xMove 1 -yMove 0 } # Right
        40 { New-Position -Object $Script:Player -xMove 0 -yMove 1 } # Down
        81 { Clear-Host; Exit }
        Default { $Key }
    }
}

Function Start-Loop {
    While ($true) {
        Update-State
        Update-Draw
        Get-Input
        Clear-Host
    }
}

Function Initialize-Game {
    $Script:Player = New-Object Player -Property @{Symbol="🧙"; Name="Player"; Level=1; Experience=0; HealthPoints=15; MaxHealthPoints=15; AttackPower=3; DefensePower=2; Position=@{x=6;y=12}}
    $Troll = New-Object Monster -Property @{Symbol="🧌"; Name="Troll"; Level=1; Experience=5; HealthPoints=5; MaxHealthPoints=5; AttackPower=2; DefensePower=1; Position=@{x=16;y=6}}
    $Dragon = New-Object Monster -Property @{Symbol="🐉"; Name="Dragon"; Level=10; Experience=500; HealthPoints=1000; MaxHealthPoints=1000; AttackPower=200; DefensePower=100; Position=@{x=2;y=4}}
    $Ghost = New-Object Monster -Property @{Symbol="👻"; Name="Ghost"; Level=2; Experience=20; HealthPoints=2; MaxHealthPoints=10; AttackPower=5; DefensePower=0; Position=@{x=20;y=14}}

    $Script:Enemies = @(
        $Troll
        $Dragon
        $Ghost
    )
#    $Script:Items = @()
#
#    $Script:ActiveObjects = @($Script:Player, $Script:Enemies, $Script:Items)

    $Script:Room = New-RandomRoom
    #$Script:Rooms += @(New-RandomRoom)
    Start-Loop
}
Initialize-Game
