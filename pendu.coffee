# https://ronlinu.github.io/pendu

state =
    revealedWord : ''
    hiddenWord   : ''
    gamesCounter : 0
    failsCounter : 0

    keyboardKeys : []
    gameKey      : null

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
showAlert = (title, icon, align, msg) ->
    new Promise (resolve) ->
        Swal.fire
            title: title
            html: "<div style='text-align: #{align}; font-size: 16px;'>#{msg}</div>"
            icon: icon
            confirmButtonText: 'OK'
            position: align
            animation: true
            willClose: resolve

# --------------------------------------
sleep = (ms) ->
    new Promise (resolve) -> setTimeout resolve, ms

# --------------------------------------
show_labels = ->
    scores = document.getElementById('scores')
    s = '&nbsp;'
    prefix = '<li><kbd style="font-size: 16px;">' + "#{s}#{s}#{s}#{s}"

    labels  = "#{prefix}Partie no: #{state.gamesCounter}</kbd></li>"
    labels += "#{prefix}Mot caché: #{state.revealedWord}</kbd></li>"
    labels += "#{prefix}#{s}#{s}#{s}Échecs: #{state.failsCounter}</kbd></li>"
    labels += "<li>#{s}</li>"

    scores.innerHTML = labels

# --------------------------------------
create_keyboard = ->
    footer = document.getElementById('footer')

    # Create keyboard container
    keyboard = document.createElement('div')
    keyboard.style.marginTop = '10px'
    footer.appendChild keyboard

    # Define rows of alphabet keys
    rows = [
        ['Q','W','E','R','T','Y','U','I','O','P']
        ['A','S','D','F','G','H','J','K','L']
        ['Z','X','C','V','B','N','M']
        ['COMMENCER', 'AU SUJET']
    ]

    # Function to create a key button
    createKey = (letter) ->
        btn = document.createElement('button')
        btn.textContent = letter
        btn.style.cursor = 'pointer'

        if letter.length == 1
            state.keyboardKeys.push btn   # record alpha key reference
            btn.style.margin = '2px'
            btn.style.padding = '5px 14px'
            btn.style.fontSize = '16px'
            btn.disabled = true;
        else if letter == 'COMMENCER'
            state.gameKey = btn         # record game key reference
            btn.style.margin = '5px'
            btn.style.padding = '5px 16px'
            btn.style.fontSize = '16px'
        else
            btn.style.margin = '5px'
            btn.style.padding = '5px 16px'
            btn.style.fontSize = '16px'

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

# ----------------------------------------------------------------------
reveal = (letter) ->
    collator = new Intl.Collator('fr', {sensitivity: 'base'})
    revealed = state.revealedWord.split('')

    for ch, index in state.hiddenWord
        if collator.compare(ch, letter) == 0
            revealed[index] = state.hiddenWord[index]

    state.revealedWord = revealed.join('')

# --------------------------------------
guess = (letter) ->
    beforeReveal = state.revealedWord
    reveal letter
    show_labels()

    if state.revealedWord is beforeReveal
        state.failsCounter++
        show_labels()
        image_file = "pendu/pendu_#{state.failsCounter}.png"
        document.getElementById('gallows').src = image_file

    if state.failsCounter == 10
        state.revealedWord = state.hiddenWord
        show_labels()
        key.disabled = true for key in state.keyboardKeys
        state.gameKey.textContent = 'NOUVEAU MOT'
        
        showAlert('Vous avez perdu!', 'info', 'center',
                "Le mot caché était: #{state.hiddenWord}")
    else if state.revealedWord is state.hiddenWord
        key.disabled = true for key in state.keyboardKeys
        state.gameKey.textContent = 'NOUVEAU MOT'
        showAlert('Bravo!', 'info', 'center', "Vous avez gagné.")

# --------------------------------------
reveal_word = ->
    do ->
        result = await askConfirm('Attention', 'question',
        'Révéler le mot caché terminera cette partie.<br><br>Êtes-vous certain?')

        if result.isConfirmed
            # disable all virtual alphabetical keys
            key.disabled = true for key in state.keyboardKeys
            state.revealedWord = state.hiddenWord
            state.gameKey.textContent = 'NOUVEAU MOT'
            show_labels()

# --------------------------------------
generate_new_word = ->
    # pick a random word from WORDS[] array defined in pendu_mots.js file
    while true
        state.hiddenWord = WORDS[Math.floor(Math.random() * WORDS.length)].toLowerCase()
        # Avoid extra-long words (limit subject to change...)
        if state.hiddenWord.length <= 20 then break

    state.revealedWord = '*'.repeat(state.hiddenWord.length)

    reveal '('
    reveal ')'
    reveal '-'

    state.gamesCounter++
    state.failsCounter = 0

    # enable all virtual alphabetic keys
    key.disabled = false for key in state.keyboardKeys

    showAlert("Partie no. #{state.gamesCounter}", '', 'center',
        "Mot caché de #{state.hiddenWord.length} lettres")

    document.getElementById('gallows').src = 'pendu/pendu_0.png'
    show_labels()
    state.gameKey.textContent = 'RÉVÉLER MOT'

# --------------------------------------
play = ->
    switch state.gameKey.textContent
        when 'COMMENCER', 'NOUVEAU MOT'
            generate_new_word()
        when 'RÉVÉLER MOT'
            reveal_word()

# ------------------------ Get game ready ----------------------------
show_labels()
create_keyboard()
