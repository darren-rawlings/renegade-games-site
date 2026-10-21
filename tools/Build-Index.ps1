<#
.SYNOPSIS
  Rebuilds index.html from the games' store listings (C:\GameDev\PlayStore\listings.json), so
  the website and Google Play describe each game the same way.

.DESCRIPTION
  Each game gets its banner (images/<slug>-banner.jpg), its short description, the first
  paragraph of its full description and its bullet points. Set a game's Play link in $live
  below once it's public, and its "coming soon" label becomes a Google Play button.
#>
$ErrorActionPreference = 'Stop'
$site = Split-Path $PSScriptRoot -Parent
$data = Get-Content 'C:\GameDev\PlayStore\listings.json' -Raw -Encoding UTF8 | ConvertFrom-Json
function Enc([string]$s) { [System.Net.WebUtility]::HtmlEncode($s) }

$slug = @{ ConnectFour = 'counter-fire'; Backgammon = 'backgammon'; Checkers = 'checkers'; CodeBreaker = 'code-breaker'
	DotsAndBoxes = 'dots-and-boxes'; Mancala = 'mancala'; Reversi = 'reversi'; SeaBattle = 'sea-battle'
	TowerOfHanoi = 'tower-of-hanoi'; UltimateTicTacToe = 'ultimate-tic-tac-toe' }
$players = @{ CodeBreaker = '1 player'; TowerOfHanoi = '1 player'; SeaBattle = '1 player vs the computer' }
$sections = [ordered]@{
	'Board games' = @('ConnectFour', 'Backgammon', 'Checkers', 'DotsAndBoxes', 'Mancala', 'Reversi', 'SeaBattle', 'UltimateTicTacToe')
	'Puzzles'     = @('CodeBreaker', 'TowerOfHanoi')
}
# Once a game is public on Google Play, add it here: Folder = $true.
$live = @{}

$cards = foreach ($section in $sections.Keys) {
	"  <h2 class=""section-title"" id=""$($section.ToLower() -replace ' ', '-')"">$(Enc $section)</h2>"
	'  <div class="games">'
	foreach ($folder in $sections[$section]) {
		$g = $data.games | Where-Object folder -eq $folder
		$parts = $g.full -split "`n`n"
		$intro = $parts[0]
		$bullets = ($g.full -split "`n" | Where-Object { $_ -like '•*' }) -replace '^•\s*', ''
		$who = if ($players[$folder]) { $players[$folder] } else { '1 or 2 players' }
		$store = if ($live[$folder]) { "<a class=""store"" href=""https://play.google.com/store/apps/details?id=$($g.package)"">Get it on Google Play</a>" }
			else { '<span class="store soon">Coming soon to Google Play</span>' }
		$lazy = if ($folder -eq 'ConnectFour') { '' } else { ' loading="lazy"' }
@"
    <article class="game" id="$($slug[$folder])">
      <img src="images/$($slug[$folder])-banner.jpg" width="1024" height="500"$lazy alt="$(Enc $g.title): the game's icon beside a phone showing it">
      <div class="game-body">
        <h3>$(Enc $g.title)</h3>
        <p class="lead">$(Enc $g.short)</p>
        <p>$(Enc $intro)</p>
        <ul class="points">
$(($bullets | ForEach-Object { "          <li>$(Enc $_)</li>" }) -join "`n")
        </ul>
        <ul class="tags">
          <li>$(Enc $who)</li>
          <li>Free with ads</li>
          <li>For all ages</li>
        </ul>
        <div class="stores">$store</div>
      </div>
    </article>
"@
	}
	'  </div>'
}

$html = @"
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Renegade Games</title>
<meta name="description" content="Renegade Games makes classic board games and puzzles for Android phones, in real 3D: Counter Fire, Backgammon, Checkers, Mancala, Reversi and more. Free, for all ages, and they play offline.">
<meta property="og:title" content="Renegade Games">
<meta property="og:description" content="Ten classic board games and puzzles for Android, in real 3D. Free, for all ages.">
<meta property="og:image" content="https://renegade-games.com/images/renegade-games-backdrop.jpg">
<meta property="og:url" content="https://renegade-games.com/">
<link rel="stylesheet" href="style.css">
</head>
<body>
<header class="hero">
  <h1>Renegade <span>Games</span></h1>
  <p>Small games, made with care.</p>
  <p class="hero-note">Ten classic board games and puzzles for Android, in real 3D.<br>In testing now, and coming soon to Google Play.</p>
  <nav class="jump" aria-label="Jump to a game">
$(($sections.Values | ForEach-Object { $_ } | ForEach-Object { $g = $data.games | Where-Object folder -eq $_; "    <a href=""#$($slug[$_])"">$(Enc ($g.title -replace ':.*', ''))</a>" }) -join "`n")
  </nav>
</header>

<main>
  <section class="shared" aria-labelledby="shared-title">
    <h2 class="section-title" id="shared-title">In every game</h2>
    <div class="features">
      <div><h3>Real 3D boards</h3><p>Drag sideways to spin the board and see it from any side. Pieces drop, roll and clack like the real thing.</p></div>
      <div><h3>Make it yours</h3><p>Five board materials and five piece finishes: plastic, wood, metal, glass and marble. The sounds change to match.</p></div>
      <div><h3>A friend or the computer</h3><p>In the two-player games, pass the phone to play a friend, or take on the computer at Easy, Medium or Hard.</p></div>
      <div><h3>Learn in seconds</h3><p>Each game has a quick tutorial with short clips, and a demo that plays a round for you.</p></div>
      <div><h3>No account, plays offline</h3><p>Just open it and play. No sign-up, no login, and no internet needed for the games themselves.</p></div>
      <div><h3>Family friendly</h3><p>Made for all ages. Ads are rated G and never personalised, and an optional one-time purchase removes them.</p></div>
    </div>
  </section>

$($cards -join "`n")

  <section class="faq" aria-labelledby="faq-title">
    <h2 class="section-title" id="faq-title">Questions</h2>
    <details>
      <summary>Are the games free?</summary>
      <p>Yes. Every game is free to download and play. There's an ad between games now and then; you can remove all ads from a game with an optional one-time purchase in its Settings. You can also leave a tip there if you'd like to support us.</p>
    </details>
    <details>
      <summary>Are they suitable for children?</summary>
      <p>Yes. The games are for all ages, and they follow Google Play's Families policy. Ads are set up for children: only family-friendly ads, never personalised. Purchases go through Google Play's own screen, which asks for a password or a parent's approval.</p>
    </details>
    <details>
      <summary>Do I need an internet connection?</summary>
      <p>No. The games play offline. Ads only appear when you're connected.</p>
    </details>
    <details>
      <summary>Do I need an account?</summary>
      <p>No. There's nothing to sign up for. Your settings are saved on your phone.</p>
    </details>
    <details>
      <summary>Which phones do they run on?</summary>
      <p>Android phones, through Google Play. They're built for phones held upright.</p>
    </details>
    <details>
      <summary>When can I get them?</summary>
      <p>The games are being tested now and will arrive on Google Play soon. Each game's button on this page will link straight to it.</p>
    </details>
    <details>
      <summary>I found a problem, or have an idea.</summary>
      <p>We'd love to hear it. Email <a href="mailto:support@renegade-games.com">support@renegade-games.com</a> and tell us which game and what happened.</p>
    </details>
  </section>
</main>

<footer>
  <p>Questions or problems? Email <a href="mailto:support@renegade-games.com">support@renegade-games.com</a></p>
  <p class="small"><a href="privacy.html">Privacy policy</a> · © 2026 Renegade Games</p>
</footer>
</body>
</html>
"@
[IO.File]::WriteAllText((Join-Path $site 'index.html'), $html, (New-Object Text.UTF8Encoding $false))
Write-Host "Wrote index.html"
