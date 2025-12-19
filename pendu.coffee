    
game =
    revealedWord : ''
    hiddenWord   : ''
    gamesCounter : ''   # does not show zero
    failsCounter : ''   # same

    keyboardKeys : []
    gameKey      : null
    
# --------------------------------------
createKeyboard = ->
    footer = document.getElementById('footer')
    keyboard = document.createElement('div')    # keyboard container
    keyboard.style.marginTop = '10px'
    footer.appendChild keyboard

    # Define rows of alphabetic keys
    rows = [
        ['A','B','C','D','E','F','G']
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
                when 'COMMENCER'
                    play()
                when 'AU SUJET'
                    aide = document.getElementById("aide").innerHTML
                    showDialog(aide)
                else
                    btn.disabled = true
                    guess buttonName

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

        return btn
    # ----------------------------------
    
    # Generate virtual keyboard
    for row in rows
        rowDiv = document.createElement('div')
        rowDiv.style.marginBottom = '5px'

        for buttonName in row
            rowDiv.appendChild createButton(buttonName)

        keyboard.appendChild rowDiv

# --------------------------------------
updateLabels = ->
    scores = document.getElementById('scores')
    s = '&nbsp;'
    prefix = '<li><kbd style="font-size: 16px;">' + "#{s}#{s}#{s}#{s}"

    labels  = "#{prefix}Partie no: #{game.gamesCounter}</kbd>"
    labels += "#{prefix}Mot caché: #{game.revealedWord}</kbd>"
    labels += "#{prefix}#{s}#{s}#{s}Échecs: #{game.failsCounter}</kbd>"

    scores.innerHTML = labels

# -------------------------------------
reveal = (letter) ->
    collator = new Intl.Collator('fr', {sensitivity: 'base'})
    revealed = game.revealedWord.split('')

    for ch, index in game.hiddenWord when collator.compare(ch, letter) is 0
        revealed[index] = game.hiddenWord[index]

    game.revealedWord = revealed.join('')

# --------------------------------------
guess = (letter) ->
    beforeReveal = game.revealedWord
    reveal letter
    updateLabels()

    if game.revealedWord is beforeReveal
        game.failsCounter++
        updateLabels()
        image_file = "resources/pendu_#{game.failsCounter}.png"
        document.getElementById('gallows').src = image_file

    if game.failsCounter == 10
        game.revealedWord = game.hiddenWord
        updateLabels()
        key.disabled = true for key in game.keyboardKeys
        game.gameKey.textContent = 'NOUVEAU MOT'
        
        showDialog "Vous avez perdu!<br>Le mot caché était: #{game.hiddenWord}"
    else if game.revealedWord is game.hiddenWord
        key.disabled = true for key in game.keyboardKeys
        game.gameKey.textContent = 'NOUVEAU MOT'
        showDialog "Bravo!<br>Vous avez gagné."

# --------------------------------------
reveal_word = ->
  msg = 'Révéler le mot caché terminera cette partie.<br><br>Êtes-vous certain?'
  showConfirmDialog(msg).then (confirmed) ->
    if confirmed
        # disable all virtual alphabetical keys
        key.disabled = true for key in game.keyboardKeys
        game.revealedWord = game.hiddenWord
        game.gameKey.textContent = 'NOUVEAU MOT'
        updateLabels()

# --------------------------------------
generate_new_word = ->
    # pick random word from WORDS[] array defined in pendu_mots.js
    while true
        game.hiddenWord = window.WORDS[Math.floor(Math.random() * window.WORDS.length)].toLowerCase()
        # Avoid extra-long words (limit subject to change...)
        if game.hiddenWord.length <= 20 then break

    game.revealedWord = '*'.repeat(game.hiddenWord.length)

    reveal '('
    reveal ')'
    reveal '-'

    game.gamesCounter++
    game.failsCounter = ''

    # enable all virtual alphabetic keys
    key.disabled = false for key in game.keyboardKeys

    document.getElementById('gallows').src = 'resources/pendu_0.png'
    updateLabels()
    game.gameKey.textContent = 'RÉVÉLER MOT'

    showDialog "Partie no. #{game.gamesCounter}<br><br>" + 
        "Mot caché de #{game.hiddenWord.length} lettres"
# --------------------------------------
play = ->
    switch game.gameKey.textContent
        when 'COMMENCER', 'NOUVEAU MOT'
            generate_new_word()
        when 'RÉVÉLER MOT'
            reveal_word()

# --------------------------------------
showDialog = (message) ->
  dialog = document.createElement('dialog')
  dialog.innerHTML = """
    <p>#{message}</p>
    <center>
      <button id="okBtn">OK</button>
    </center>
  """

  document.body.appendChild(dialog)
  dialog.showModal()

  okBtn = dialog.querySelector('#okBtn')
  okBtn.onclick = ->
    dialog.close()
    dialog.remove()
  
# --------------------------------------
showConfirmDialog = (message) ->
  dialog = document.createElement('dialog')
  dialog.innerHTML = """
    <p>#{message}</p>
    <center>
      <button id="okBtn">Oui</button>
      <button id="cancelBtn">Non</button>
    </center>
  """

  # OK button
  okBtn = dialog.querySelector('#okBtn')
  okBtn.onclick = ->
    dialog.returnValue = 'ok'
    dialog.close()
    dialog.remove()

  # Cancel button
  cancelBtn = dialog.querySelector('#cancelBtn')
  cancelBtn.onclick = ->
    dialog.close()
    dialog.remove()

  document.body.appendChild(dialog)
  dialog.showModal()

  # Return Promise for async result
  new Promise (resolve) ->
    dialog.onclose = ->
      result = dialog.returnValue
      resolve(result == 'ok')

# **************************************
do ->
    createKeyboard()
