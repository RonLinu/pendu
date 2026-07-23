###
  French version of Hangman
  To be compiled with Coffee ST
###

game =
  revealedWord : ''
  hiddenWord   : ''
  gameCounter : 0
  failCounter : 0
  keyboardKeys : []
  gameKey      : null

# --------------------------------------
createKeyboard = ->
  footer = document.getElementById('footer')
  keyboard = document.createElement('div')    # keyboard container
  keyboard.style.margin= '10px'
  footer.appendChild keyboard

  # Define rows of alphabetic keys
  rows = [ ['A','B','C','D','E','F','G']
    ['H','I','J','K','L','M','N']
    ['O','P','Q','R','S','T','U']
    ['V','W','X','Y','Z']
    ['COMMENCER', 'AU SUJET']
  ]

  # ----- Local function to create one virtual keyboard button
  createButton = (buttonName) ->
    btn = document.createElement('button')

    btn.onclick = ->
      switch buttonName
        when 'COMMENCER' then play()
        when 'AU SUJET' then auSujet()
        else
          btn.disabled = true
          guess buttonName
      \switch
    \Function

    btn.textContent = buttonName
    btn.style.cursor = 'pointer'
    btn.style.margin = '2px'
    btn.style.padding = '5px 14px'
    btn.style.fontSize = '16px'

    if buttonName.length == 1
      game.keyboardKeys.push btn   # record alpha key reference
      btn.disabled = true
    else if buttonName == 'COMMENCER'
      game.gameKey = btn         # record game key reference
    \if

    return btn
  \Function

  # Generate virtual keyboard
  for row in rows
    rowDiv = document.createElement('div')
    rowDiv.style.marginBottom = '5px'

    rowDiv.appendChild createButton(buttonName) for buttonName in row
    keyboard.appendChild rowDiv
  \for
\Function

# --------------------------------------
auSujet = ->
  aide =
  '''<center><b>Pendu © 2025 - RonLinu</b></center><br>
    Ce jeu bien connu consiste à deviner, une lettre à la fois,
    un mot caché qui est choisi au hazard parmi plus de
    17000 mots français.<br><br>
    Si vous accumulez 10 échecs sans avoir trouvé un mot caché,
    vous perdez 😞<br><br>
    Cliquer sur une lettre dévoile aussi toutes les lettres
    accentuées correspondantes.<br>
  '''

  showDialog(aide)
\Function

# --------------------------------------
updateLabels = ->
  scores = document.getElementById('scores')
  sp = '&nbsp;'
  prefix = '<li><kbd style="font-size: 16px;">' + "#{sp}#{sp}#{sp}#{sp}"

  labels  = "#{prefix}Partie no: #{game.gameCounter}</kbd>"
  labels += "#{prefix}Mot caché: #{game.revealedWord}</kbd>"
  labels += "#{prefix}#{sp}#{sp}Manqués: #{game.failCounter}</kbd>"

  scores.innerHTML = labels
\Function

# -------------------------------------
reveal = (letter) ->
  collator = new Intl.Collator('fr', {sensitivity: 'base'})
  revealed = game.revealedWord.split('')

  for ch, index in game.hiddenWord when collator.compare(ch, letter) is 0
    revealed[index] = game.hiddenWord[index]
  \for

  game.revealedWord = revealed.join('')
\Function

# --------------------------------------
guess = (letter) ->
  beforeReveal = game.revealedWord
  reveal letter
  updateLabels()

  if game.revealedWord is beforeReveal
    game.failCounter++
    updateLabels()
    image_file = "resources/pendu_#{game.failCounter}.png"
    document.getElementById('gallows').src = image_file
  \if

  if game.failCounter == 10
    game.revealedWord = game.hiddenWord
    updateLabels()
    key.disabled = true  for key in game.keyboardKeys
    game.gameKey.textContent = 'NOUVEAU MOT'
    showDialog "<center>Vous avez perdu!</center><br><center>Le mot caché était: #{game.hiddenWord}</center>"

  else if game.revealedWord is game.hiddenWord
    key.disabled = true  for key in game.keyboardKeys
    game.gameKey.textContent = 'NOUVEAU MOT'
    showDialog "<center>Bravo!<center><br><center>Vous avez gagné.</center>"
  \if
\Function

# --------------------------------------
reveal_word = ->
  msg = 'Révéler le mot caché terminera cette partie.<br><br><center>Êtes-vous certain?</center>'

  answer = await showConfirmDialog(msg, leftLabel:'Oui', rightLabel:'Non')

  if answer is 'Oui'
    # disable all virtual alphabetical keys
    key.disabled = true  for key in game.keyboardKeys
    game.revealedWord = game.hiddenWord
    game.gameKey.textContent = 'NOUVEAU MOT'
    updateLabels()
  \if
\Function

# --------------------------------------
generate_new_word = ->
  loop
    # pick random word from WORDS[] array defined in pendu_mots.js
    game.hiddenWord = window.WORDS[Math.floor(Math.random() * window.WORDS.length)].toLowerCase()
    break if game.hiddenWord.length <= 20
  \loop

  game.revealedWord = '*'.repeat(game.hiddenWord.length)

  reveal '('
  reveal ')'
  reveal '-'

  game.gameCounter++
  game.failCounter = ''

  # enable all virtual alphabetic keys
  key.disabled = false  for key in game.keyboardKeys

  document.getElementById('gallows').src = 'resources/pendu_0.png'
  updateLabels()
  game.gameKey.textContent = 'RÉVÉLER MOT'

  showDialog "<center>Partie no. #{game.gameCounter}<center><br>" +
  "<center>Mot caché de #{game.hiddenWord.length} lettres</center>"
\Function

# --------------------------------------
play = ->
  switch game.gameKey.textContent
    when 'COMMENCER', 'NOUVEAU MOT'
      generate_new_word()
    when 'RÉVÉLER MOT'
      reveal_word()
  \switch
\Function

# **************************************
do ->
  createKeyboard()
  scores = document.getElementById('scores')
  prefix = '<li><kbd style="font-size: 16px;">&nbsp;</kbd></li>'
  scores.innerHTML = prefix + prefix + prefix
\Function
