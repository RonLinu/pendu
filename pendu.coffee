# https://ronlinu.github.io/pendu

game =
    revealedWord : ''
    hiddenWord   : ''
    gamesCounter : ''   # does not show zero
    failsCounter : ''   # same

    keyboardKeys : []
    gameKey      : null

# --------------------------------------
do ->       # Create the keyboard with its event handlers
    footer = document.getElementById('footer')

    # Create keyboard container
    keyboard = document.createElement('div')
    keyboard.style.marginTop = '10px'
    footer.appendChild keyboard

    # Define rows of alphabet keys
    rows = [
        ['A','B','C','D','E','F','G']
        ['H','I','J','K','L','M','N']
        ['O','P','Q','R','S','T','U']
        ['V','W','X','Y','Z']
        ['COMMENCER', 'AU SUJET']
    ]

    # ----- Local function to create a key button
    createKey = (letter) ->
        btn = document.createElement('button')
        btn.textContent = letter
        btn.style.cursor = 'pointer'

        if letter.length == 1
            game.keyboardKeys.push btn   # record alpha key reference
            btn.style.margin = '2px'
            btn.style.padding = '5px 14px'
            btn.style.fontSize = '16px'
            btn.disabled = true;
        else if letter == 'COMMENCER'
            game.gameKey = btn         # record game key reference
            btn.style.margin = '5px'
            btn.style.padding = '5px 16px'
            btn.style.fontSize = '16px'
            btn.style.background = 'lightgray'
        else
            btn.style.margin = '5px'
            btn.style.padding = '5px 16px'
            btn.style.fontSize = '16px'
            btn.style.background = 'lightgray'

        btn.onclick = ->
            switch letter
                when 'COMMENCER'
                    play()
                when 'AU SUJET'
                    showAlert('Au sujet de Pendu', '', 'left', AIDE)
                else
                    btn.disabled = true
                    guess letter
        return btn
    
    # Generate keys row-wise
    for row in rows
        rowDiv = document.createElement('div')
        rowDiv.style.marginBottom = '5px'
        for letter in row
            rowDiv.appendChild createKey(letter)
        keyboard.appendChild rowDiv

# --------------------------------------
showAlert = (title, icon, textalign, msg) ->
    Swal.fire
        title: title
        html: "<div style='text-align: #{textalign}; font-size: 16px;'>#{msg}</div>"
        icon: icon
        confirmButtonText: 'OK'
        position: 'center'
        animation: true

# --------------------------------------
askConfirm = (title, icon, message) ->
    Swal.fire
        title: title
        html: message
        icon: icon
        showCancelButton: true
        confirmButtonText: 'Oui'
        cancelButtonText: 'Non'
        focusCancel: true
        position: 'center'

# --------------------------------------
show_labels = ->
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

    for ch, index in game.hiddenWord
        if collator.compare(ch, letter) == 0
            revealed[index] = game.hiddenWord[index]

    game.revealedWord = revealed.join('')

# --------------------------------------
guess = (letter) ->
    beforeReveal = game.revealedWord
    reveal letter
    show_labels()

    if game.revealedWord is beforeReveal
        game.failsCounter++
        show_labels()
        image_file = "pendu/pendu_#{pendu.failsCounter}.png"
        document.getElementById('gallows').src = image_file

    if game.failsCounter == 10
        game.revealedWord = game.hiddenWord
        show_labels()
        key.disabled = true for key in game.keyboardKeys
        game.gameKey.textContent = 'NOUVEAU MOT'
        
        showAlert('Vous avez perdu!', 'info', 'center',
                "Le mot caché était: #{game.hiddenWord}")
    else if game.revealedWord is game.hiddenWord
        key.disabled = true for key in game.keyboardKeys
        game.gameKey.textContent = 'NOUVEAU MOT'
        showAlert('Bravo!', 'info', 'center', "Vous avez gagné.")

# --------------------------------------
reveal_word = ->
    result = await askConfirm('Attention', 'question',
    'Révéler le mot caché terminera cette partie.<br><br>Êtes-vous certain?')

    if result.isConfirmed
        # disable all virtual alphabetical keys
        key.disabled = true for key in game.keyboardKeys
        game.revealedWord = game.hiddenWord
        game.gameKey.textContent = 'NOUVEAU MOT'
        show_labels()

# --------------------------------------
generate_new_word = ->
    # pick a random word from WORDS[] array defined in pendu_mots.js file
    while true
        game.hiddenWord = WORDS[Math.floor(Math.random() * WORDS.length)].toLowerCase()
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

    document.getElementById('gallows').src = 'pendu/pendu_0.png'
    show_labels()
    game.gameKey.textContent = 'RÉVÉLER MOT'

    showAlert("Partie no. #{game.gamesCounter}", '', 'center',
        "Mot caché de #{game.hiddenWord.length} lettres")

# --------------------------------------
play = ->
    switch game.gameKey.textContent
        when 'COMMENCER', 'NOUVEAU MOT'
            generate_new_word()
        when 'RÉVÉLER MOT'
            reveal_word()
