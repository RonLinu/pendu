###
  Jeu de Pendu en francais
  Ecrit avec CoffeeDelim
###

game =
  revealedWord : ''
  hiddenWord   : ''
  gameCounter  : ''      # empty string, does not show as zero
  failCounter  : ''      # same
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
  Object createButton = (buttonName) ->
    btn = document.createElement('button')

    btn.onclick = ->
      switch buttonName:
        when 'COMMENCER':
          play()
        when 'AU SUJET':
          aide = document.getElementById("aide").innerHTML
          showDialog(aide)
        else:
          btn.disabled = true
          guess buttonName
      end switch
    end

    btn.textContent = buttonName
    btn.style.cursor = 'pointer'
    btn.style.margin = '2px'
    btn.style.padding = '5px 14px'
    btn.style.fontSize = '16px'

    if buttonName.length == 1:
      game.keyboardKeys.push btn   # record alpha key reference
      btn.disabled = true
    else if buttonName is 'COMMENCER':
      game.gameKey = btn         # record game key reference
    end if

    return btn
  end

  # Generate virtual keyboard
  for row in rows:
    rowDiv = document.createElement('div')
    rowDiv.style.marginBottom = '5px'

    for buttonName in row then rowDiv.appendChild createButton(buttonName)
    keyboard.appendChild rowDiv
  end for
end

# --------------------------------------
updateLabels = ->
  scores = document.getElementById('scores')
  sp = '&nbsp;'
  prefix = '<li><kbd style="font-size: 16px;">' + "#{sp}#{sp}#{sp}#{sp}"

  labels  = "#{prefix}Partie no: #{game.gameCounter}</kbd>"
  labels += "#{prefix}Mot caché: #{game.revealedWord}</kbd>"
  labels += "#{prefix}#{sp}#{sp}Manqués: #{game.failCounter}</kbd>"

  scores.innerHTML = labels
end

# -------------------------------------
reveal = (letter) ->
  collator = new Intl.Collator('fr', {sensitivity: 'base'})
  revealed = game.revealedWord.split('')

  for ch, index in game.hiddenWord when collator.compare(ch, letter) is 0 :
    revealed[index] = game.hiddenWord[index]
  end for

  game.revealedWord = revealed.join('')
end

# --------------------------------------
guess = (letter) ->
  beforeReveal = game.revealedWord
  reveal letter
  updateLabels()

  if game.revealedWord is beforeReveal:
    game.failCounter++
    updateLabels()
    image_file = "resources/pendu_#{game.failCounter}.png"
    document.getElementById('gallows').src = image_file
  end if

  if game.failCounter == 10:
    game.revealedWord = game.hiddenWord
    updateLabels()
    key.disabled = true for key in game.keyboardKeys
    game.gameKey.textContent = 'NOUVEAU MOT'
    showDialog "<center>Vous avez perdu!</center><br><center>Le mot caché était: #{game.hiddenWord}</center>"
  else if game.revealedWord is game.hiddenWord:
    key.disabled = true for key in game.keyboardKeys
    game.gameKey.textContent = 'NOUVEAU MOT'
    showDialog "<center>Bravo!<center><br><center>Vous avez gagné.</center>"
  end if
end

# --------------------------------------
reveal_word = ->
  msg = 'Révéler le mot caché terminera cette partie.<br><br><center>Êtes-vous certain?</center>'

  answer = await showConfirmDialog(msg, leftLabel:'Oui', rightLabel:'Non')

  # disable all virtual alphabetical keys if revealed
  if answer is 'Oui':
    key.disabled = true for key in game.keyboardKeys
    game.revealedWord = game.hiddenWord
    game.gameKey.textContent = 'NOUVEAU MOT'
    updateLabels()
  end if
end

# --------------------------------------
generate_new_word = ->
  loop:
    # pick random word from WORDS[] array defined in pendu_mots.js
    game.hiddenWord = window.WORDS[Math.floor(Math.random() * window.WORDS.length)].toLowerCase()
    break if game.hiddenWord.length <= 20
  end

  game.revealedWord = '*'.repeat(game.hiddenWord.length)

  reveal '('
  reveal ')'
  reveal '-'

  game.gameCounter++
  game.failCounter = ''

  # enable all virtual alphabetic keys
  key.disabled = false for key in game.keyboardKeys

  document.getElementById('gallows').src = 'resources/pendu_0.png'
  updateLabels()
  game.gameKey.textContent = 'RÉVÉLER MOT'

  showDialog "<center>Partie no. #{game.gameCounter}<center><br>" +
  "<center>Mot caché de #{game.hiddenWord.length} lettres</center>"
end

# --------------------------------------
play = ->
  switch game.gameKey.textContent:
    when 'COMMENCER', 'NOUVEAU MOT':
      generate_new_word()
    when 'RÉVÉLER MOT':
      reveal_word()
  end switch
end

# **************************************
do ->
  createKeyboard()

  scores = document.getElementById('scores')
  prefix = '<li><kbd style="font-size: 16px;">&nbsp;</kbd></li>'
  scores.innerHTML = prefix + prefix + prefix
end
