# MyTodoList — identité de marque

## 1. Le concept — « Le Sceau du jour »

> Un disque corail plein : la journée, entière et recommencée chaque matin.  
> Une coche évidée : ce qui est fait, imprimé dans cette journée.  
> Le plein et le creux font la progression ; la diagonale montante donne l'élan.  
> Une masse, deux formes, aucun texte : le mark tient de 20 px à 1024.

**Pourquoi ce mark pour MyTodoList**

- **Rythme quotidien** — le disque est le jour ; l'app est construite autour d'« Aujourd'hui », de la semaine glissante et du calendrier.
- **Validation** — la coche est le geste central de l'app (case ronde, barre de progression, « coche-les »). Elle est ici un *vide*, pas une icône de plus : elle se lit comme une marque laissée dans la journée, pas comme un contrôle d'interface.
- **Élan** — le grand bras monte à ~50°, comme le « avance » du slogan ; le disque est stable, la coche est dynamique.
- **Cohérence avec le thème** — la coche est transparente : sur le thème sombre elle prend la couleur du fond `#14141B`, sur le thème clair celle de `#F3F2EF`. Le mark utilise littéralement le fond comme encre.
- **Lisibilité** — une masse pleine + un contrepoids négatif. À 20 px, le trait de coche fait 2,3 px et la couronne 2,2 px : aucun détail fin, aucun dégradé, aucune police.

## 2. Construction

| Élément | Valeur |
|---|---|
| Canevas source | `viewBox="0 0 1024 1024"`, fond transparent |
| Disque | centre `(512, 512)`, rayon `460` (Ø 920, soit 5 % de marge optique dans le fichier) |
| Coche | `M 305 500 L 472 668 L 720 368`, trait `142`, extrémités et angle arrondis |
| Formes | 2 : le disque plein + la coche évidée (masque interne, aucune ressource externe) |
| BBox de la coche | 557 × 442, centrée à `(512,5 ; 518)` — centrage optique |
| Ratio des bras | petit bras ≈ 236, grand bras ≈ 392 (0,60) ; angle ouvert ≈ 96° |
| Icône d'app | disque Ø **768** = 75 % de 1024 → **128 px de marge = 12,5 %** |
| Maskable web | disque Ø **614** = 60 % de 1024 → **205 px de marge = 20 %** |

Le fichier `logo_mark.svg` est la source de vérité. Il ne contient ni `<text>`, ni image, ni police, ni ressource externe. La coche est découpée par un `<mask>` : le trou est transparent, donc il prend toujours la couleur du fond sur lequel le mark est posé.

## 3. Palette

| Nom | Hex | Usage | Contraste |
|---|---|---|---|
| Corail vif | `#FF6B57` | mark sur fonds sombres ; accent du thème sombre | **6,54:1** sur `#14141B` |
| Corail profond | `#D9483B` | mark sur fonds clairs ; accent du thème clair | **3,80:1** sur `#F3F2EF` |
| Nuit | `#14141B` | fond de l'icône d'app, fond du thème sombre | — |
| Ardoise | `#1E1E28` | cartes et fonds sombres alternatifs | 5,9:1 avec `#FF6B57` |
| Brume | `#F3F2EF` | fond du thème clair | — |
| Blanc | `#FFFFFF` | variante monochrome blanche | 18,33:1 sur `#14141B` |
| Lumière | `#ECECF2` | texte du thème sombre (pour mémoire) | — |

**Règle de couleur :** le corail vif `#FF6B57` ne se pose **jamais** sur `#F3F2EF` ou blanc (2,50:1, sous le seuil de 3:1). Sur fond clair, on utilise `#D9483B` (`logo_mark_corail_1024.png`) ou le mono blanc sur un fond sombre.

## 4. Zone de sécurité, tailles et contextes

| Contexte | Marge | Ø du disque | Remarque |
|---|---|---|---|
| Logo source / in-app | 5 % (dans le fichier) | 920 / 1024 | prévoir en plus ≥ 20 % du Ø autour du disque dans la mise en page |
| Icône d'app (iOS, Android, web standard, Windows, favicon) | **12,5 %** | 768 / 1024 | 128 px de marge sur le master 1024 |
| Web maskable (`purpose: maskable`) | **20 %** | 614 / 1024 | 205 px ; zone renforcée, le mark reste dans le cercle de sécurité |
| Bouton d'accueil in-app | ≥ 20 % autour | 40–44 px dans le bouton 72 px | remplace `Icon(Icons.check)`, garde le `onPressed` |

**Tailles minimales**
- Icône d'app : **20 px** (iOS) — les fichiers 20 / 29 / 40 px sont fournis.
- Logo in-app : **32 px** recommandé, **20 px** minimum absolu.
- En dessous de 20 px, le disque reste lisible mais la coche devient une simple encoche : ne pas descendre plus bas.

**Espace de respiration :** au moins **20 % du diamètre du disque** entre le disque et tout autre élément (texte, bord d'écran, autre icône). La marge de 5 % intégrée au fichier n'est pas une zone de respiration.

## 5. Règles d'usage

**Fonds autorisés**
- `#14141B`, `#1E1E28`, `#2A2A36` (sombres) avec le mark `#FF6B57`.
- `#F3F2EF`, `#FFFFFF` (clairs) avec le mark `#D9483B`.
- Tout fond sombre ou coloré avec la variante **mono blanche**, à condition que le contraste soit ≥ 3:1.
- Tout fond clair ou moyen avec `#D9483B` (vérifier ≥ 3:1). Le trou de la coche prend la couleur du fond : ce contraste fond/disque est donc aussi celui de la coche.

**Interdits**
- Poser `#FF6B57` sur fond clair, ou le mono blanc sur blanc ; corail sur corail.
- Photos, dégradés, motifs chargés, fonds à faible contraste derrière le mark.
- Rotation, inclinaison, étirement, recadrage du disque, contour, ombre, glow, biseau, 3D, animation.
- Ajouter du texte dans le disque, remplacer la coche, utiliser le mark comme un « O » ou comme une case à cocher interactive.
- Recolorer hors palette ou modifier le rapport disque/coche.

**In-app**
- Le mark remplace l'`Icon(Icons.check, size: 40)` du `BoutonVerre` **72 × 72** de l'accueil, à **44 px** (le disque fait alors ~40 px) : tuile « verre » **non accentuée** (le corail ne se pose jamais sur un fond corail), thème sombre → `logo_mark_1024.png`, thème clair → `logo_mark_corail_1024.png`. Le `onPressed` et le `tooltip` sont conservés.
- Le titre « MyTodoList » reste en `p.texte` (36 px, w700, letter-spacing −0,8), le slogan en `p.texteSecondaire`.
- Le mark est une **marque**, pas un contrôle : la case ronde des tâches (`CaseRonde`, 22 px) reste l'unique contrôle de complétion.

## 6. Les deux pistes alternatives

1. **L'Arc du jour** — un anneau corail ouvert à ~280°, dont l'ouverture est franchie par une coche plus épaisse : le cycle du jour se referme sur la validation. Plus aérien, plus « progression », mais moins dense et moins net à 20 px. À privilégier si le sceau vous semble trop proche d'une tâche cochée.
2. **L'Élan** — une coche monoline seule, sans disque, dont le petit bras se courbe en arc de lever de soleil. Plus proche du slogan et plus léger en favicon, mais moins identifiable comme icône d'app et moins « sceau ».

Le **Sceau du jour** a été retenu pour sa masse (excellente tenue à 20 px), sa double lecture icône d'app / logo in-app et sa cohérence immédiate avec le corail sur nuit.

## 7. Fichiers livrés

```
app/assets/branding/
├── logo_mark.svg                      source vectorielle, 1024 × 1024, transparent
├── logo_mark_1024.png                 mark corail #FF6B57, 1024 × 1024, transparent
├── logo_mark_mono_1024.png            mark blanc #FFFFFF, 1024 × 1024, transparent
├── logo_mark_corail_1024.png          mark corail profond #D9483B, 1024 × 1024, transparent
├── app_icon_1024.png                  icône opaque #14141B, mark à 12,5 %, 1024 × 1024
├── preview_dark.png                   aperçu #14141B, 512 × 512
├── preview_light.png                  aperçu #F3F2EF, mark #D9483B, 512 × 512
└── icons/
    ├── android/
    │   ├── ic_launcher_48.png         mdpi
    │   ├── ic_launcher_72.png         hdpi
    │   ├── ic_launcher_96.png         xhdpi
    │   ├── ic_launcher_144.png        xxhdpi
    │   └── ic_launcher_192.png        xxxhdpi
    ├── ios/                           15 fichiers, noms exacts du Contents.json existant
    │   ├── Icon-App-20x20@1x.png      20
    │   ├── Icon-App-20x20@2x.png      40
    │   ├── Icon-App-20x20@3x.png      60
    │   ├── Icon-App-29x29@1x.png      29
    │   ├── Icon-App-29x29@2x.png      58
    │   ├── Icon-App-29x29@3x.png      87
    │   ├── Icon-App-40x40@1x.png      40
    │   ├── Icon-App-40x40@2x.png      80
    │   ├── Icon-App-40x40@3x.png      120
    │   ├── Icon-App-60x60@2x.png      120
    │   ├── Icon-App-60x60@3x.png      180
    │   ├── Icon-App-76x76@1x.png      76
    │   ├── Icon-App-76x76@2x.png      152
    │   ├── Icon-App-83.5x83.5@2x.png  167
    │   └── Icon-App-1024x1024@1x.png  1024
    ├── web/
    │   ├── Icon-192.png               192
    │   ├── Icon-512.png               512
    │   ├── Icon-maskable-192.png      192, mark à 20 %
    │   ├── Icon-maskable-512.png      512, mark à 20 %
    │   └── favicon-48.png             48
    └── windows/
        ├── app_icon_16.png
        ├── app_icon_24.png
        ├── app_icon_32.png
        ├── app_icon_48.png
        ├── app_icon_64.png
        ├── app_icon_128.png
        └── app_icon_256.png
```

Toutes les icônes d'app (Android, iOS, web, Windows, favicon) sont **opaques**, fond `#14141B`, mark à 12,5 % de marge — sauf les maskables, à 20 %. Les quatre marks (`logo_mark_1024`, `mono`, `corail`, et le SVG) sont **transparents**. Les iOS sont en RGB sans alpha, conformes à l'App Store.

## 8. Régénérer

**Source à éditer :** `logo_mark.svg` uniquement. Le mark = un disque `r=460` + une coche dans un masque. Pour modifier la coche, garder son trait ≥ 2,2 px à 20 px et son point le plus proche du bord à ≥ 2,2 px du disque.

**Rasteriser le SVG** (transparence conservée) avec Edge headless :

```powershell
$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
& $edge --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 `
  --window-size=1024,1024 --default-background-color=00000000 `
  --screenshot="$PWD\logo_mark_1024.png" "file:///$($PWD.Path.Replace('\','/'))/logo_mark.svg"
```

**Composer les icônes et décliner les tailles** avec `System.Drawing` (Windows, zéro dépendance) :

```powershell
Add-Type -AssemblyName System.Drawing
$root = "app/assets/branding"
$mark = [System.Drawing.Image]::FromFile("$root/logo_mark_1024.png")
$nuit = [System.Drawing.ColorTranslator]::FromHtml("#14141B")

function New-Icon([int]$px, [string]$file, [double]$ratio) {
  $bmp = [System.Drawing.Bitmap]::new($px, $px, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.Clear($nuit)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  # Le master transparent a un disque de 920 px dans 1024 : facteur 920/1024.
  $d = [int][Math]::Round($px * $ratio / (920.0 / 1024.0))
  $o = [int][Math]::Round(($px - $d) / 2)
  $g.DrawImage($mark, $o, $o, $d, $d)
  $g.Dispose()
  $bmp.Save((Join-Path $root $file), [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
}

# 12,5 % de marge -> ratio 0.75 ; maskable 20 % -> ratio 0.60
New-Icon 1024 "app_icon_1024.png" 0.75
foreach ($n in 48,72,96,144,192) { New-Icon $n "icons/android/ic_launcher_$n.png" 0.75 }
New-Icon 192 "icons/web/Icon-192.png" 0.75
New-Icon 512 "icons/web/Icon-512.png" 0.75
New-Icon 192 "icons/web/Icon-maskable-192.png" 0.60
New-Icon 512 "icons/web/Icon-maskable-512.png" 0.60
New-Icon 48  "icons/web/favicon-48.png" 0.75
foreach ($n in 16,24,32,48,64,128,256) { New-Icon $n "icons/windows/app_icon_$n.png" 0.75 }

$ios = @{
  "Icon-App-20x20@1x.png" = 20;  "Icon-App-20x20@2x.png" = 40;  "Icon-App-20x20@3x.png" = 60
  "Icon-App-29x29@1x.png" = 29;  "Icon-App-29x29@2x.png" = 58;  "Icon-App-29x29@3x.png" = 87
  "Icon-App-40x40@1x.png" = 40;  "Icon-App-40x40@2x.png" = 80;  "Icon-App-40x40@3x.png" = 120
  "Icon-App-60x60@2x.png" = 120; "Icon-App-60x60@3x.png" = 180
  "Icon-App-76x76@1x.png" = 76;  "Icon-App-76x76@2x.png" = 152
  "Icon-App-83.5x83.5@2x.png" = 167; "Icon-App-1024x1024@1x.png" = 1024
}
foreach ($k in $ios.Keys) { New-Icon $ios[$k] "icons/ios/$k" 0.75 }
$mark.Dispose()
```

Pour la variante claire, remplacer `logo_mark_1024.png` par `logo_mark_corail_1024.png` ; pour le mono, par `logo_mark_mono_1024.png`.

**Vérifier dimensions et opacité** :

```powershell
Get-ChildItem -Recurse $root -Filter *.png | ForEach-Object {
  $img = [System.Drawing.Image]::FromFile($_.FullName)
  "{0,-46} {1,4} x {2,-4} alpha={3}" -f $_.FullName.Substring($root.Length + 1), $img.Width, $img.Height, $img.PixelFormat
  $img.Dispose()
}
```

Attendu : les icônes en `Format24bppRgb` (opaques), les quatre marks en `Format32bppArgb` (transparents). L'icône 1024 doit avoir son disque entre 128 et 895 px (marge 12,5 %).

## 9. À valider par Manuel

1. **Le choix du sceau** plutôt que « L'Arc du jour » ou « L'Élan » — notamment la proximité visuelle avec une tâche cochée. Si c'est gênant, l'arc ouvert est la meilleure alternative.
2. **`logo_mark_corail_1024.png` en `#D9483B`** (corail profond) et `preview_light.png` dans cette couleur : le corail vif `#FF6B57` n'a que 2,5:1 sur `#F3F2EF`. Si vous préférez le corail vif partout, garder le mark pour les fonds sombres uniquement.
3. **La marge maskable à 20 %** (mark à 60 %) : volontairement conservatrice. La norme maskable usuelle est 10 % ; on peut passer à 15 % si le mark paraît trop petit sur l'écran d'accueil.
4. **L'intégration** (hors périmètre design) : déclarer `assets/branding/` dans `pubspec.yaml`, remplacer les icônes de plateforme, passer `manifest.json` de `#0175C2` à `#14141B` / `#FF6B57`, et remplacer l'`Icon(Icons.check)` du bouton d'accueil par le mark à 44 px. Le `onPressed` et le tooltip restent inchangés.
5. **Point d'hygiène repo** : `app/android/app/src/main/AndroidManifest.xml` était déjà modifié avant mon intervention (`git status` le montre) ; je n'y ai pas touché.
