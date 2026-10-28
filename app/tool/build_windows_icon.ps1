# Génère windows/runner/resources/app_icon.ico à partir des PNG de marque.
# Format ICO : ICONDIR, une ICONDIRENTRY de 16 octets par taille, puis les PNG
# bruts (256 px s'encode 0 dans les champs largeur/hauteur).
# Usage : powershell -File tool/build_windows_icon.ps1

$ErrorActionPreference = 'Stop'

$racine = Split-Path -Parent $PSScriptRoot
$assets = Join-Path $racine 'assets\branding\icons\windows'
$sortie = Join-Path $racine 'windows\runner\resources\app_icon.ico'
$tailles = 16, 24, 32, 48, 64, 128, 256

# Lecture des PNG et contrôle de la dimension annoncée dans IHDR.
$images = foreach ($taille in $tailles) {
  $chemin = Join-Path $assets "app_icon_$taille.png"
  if (-not (Test-Path $chemin)) { throw "PNG manquant : $chemin" }
  $octets = [System.IO.File]::ReadAllBytes($chemin)
  $signature = 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A
  for ($i = 0; $i -lt 8; $i++) {
    if ($octets[$i] -ne $signature[$i]) { throw "Pas un PNG : $chemin" }
  }
  $largeur = ([int]$octets[16] -shl 24) -bor ([int]$octets[17] -shl 16) -bor `
             ([int]$octets[18] -shl 8) -bor [int]$octets[19]
  $hauteur = ([int]$octets[20] -shl 24) -bor ([int]$octets[21] -shl 16) -bor `
             ([int]$octets[22] -shl 8) -bor [int]$octets[23]
  if ($largeur -ne $taille -or $hauteur -ne $taille) {
    throw "$chemin fait ${largeur}x${hauteur}, attendu ${taille}x${taille}"
  }
  [pscustomobject]@{ Taille = $taille; Octets = $octets }
}

$flux = [System.IO.MemoryStream]::new()
$ecrivain = [System.IO.BinaryWriter]::new($flux)

# ICONDIR : reserve (0), type 1 = icone, nombre d'images.
$ecrivain.Write([uint16]0)
$ecrivain.Write([uint16]1)
$ecrivain.Write([uint16]$images.Count)

# ICONDIRENTRY : position des donnees apres l'en-tete et le repertoire.
$offset = 6 + 16 * $images.Count
foreach ($image in $images) {
  $dimension = if ($image.Taille -ge 256) { 0 } else { $image.Taille }
  $ecrivain.Write([byte]$dimension)              # largeur
  $ecrivain.Write([byte]$dimension)              # hauteur
  $ecrivain.Write([byte]0)                       # couleurs de palette
  $ecrivain.Write([byte]0)                       # reserve
  $ecrivain.Write([uint16]1)                     # plans
  $ecrivain.Write([uint16]32)                    # bits par pixel
  $ecrivain.Write([uint32]$image.Octets.Length)  # taille des donnees
  $ecrivain.Write([uint32]$offset)               # position des donnees
  $offset += $image.Octets.Length
}
foreach ($image in $images) { $ecrivain.Write($image.Octets) }

$ecrivain.Flush()
[System.IO.File]::WriteAllBytes($sortie, $flux.ToArray())
$ecrivain.Dispose()
$flux.Dispose()

Write-Host ("app_icon.ico : {0} octets, {1} entrees ({2})" -f `
  (Get-Item $sortie).Length, $images.Count, ($tailles -join ', '))
