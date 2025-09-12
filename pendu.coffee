
state =
    gamesCounter : 0
    revealedWord : ""
    failsCounter : 0

    hiddenWord   : ""
    triedLetters : []
    keyboardKeys : []

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
    
# --------------------------------------
showAlert = (title, icon, align, message) ->
  Swal.fire
    title: title
    html: "<div style='text-align: #{align};'>#{message}</div>"
    icon: icon
    confirmButtonText: 'OK'

# --------------------------------------
sleep = (ms) ->
    new Promise (resolve) -> setTimeout resolve, ms

# --------------------------------------
update_labels = ->
    top = document.getElementById 'top'
    prefix = '<li><kbd style="font-size: 16px;">'
    labels  = "#{prefix}Partie no: #{state.gamesCounter}</kbd></li>"
    labels += "#{prefix}Mot caché: #{state.revealedWord}</kbd></li>"
    labels += "#{prefix}&nbsp;&nbsp;&nbsp;Échecs: #{state.failsCounter}</kbd></li>"
    labels += "<li></li>"
    top.innerHTML = labels

# --------------------------------------
create_keyboard = ->
    footer = document.getElementById 'footer'

    # Create keyboard container
    keyboard = document.createElement 'div'
    keyboard.style.marginTop = '10px'
    footer.appendChild keyboard

    # Define rows of alphabet keys
    rows = [
        ['q','w','e','r','t','y','u','i','o','p']
        ['a','s','d','f','g','h','j','k','l']
        ['z','x','c','v','b','n','m']
        ['Au sujet', 'Nouveau mot', 'Révéler mot']
    ]

    # Function to create a key button
    createKey = (letter) ->
        btn = document.createElement 'button'
        btn.textContent = letter.toUpperCase()
        btn.style.margin = '2px'
        btn.style.padding = '5px 14px'
        btn.style.fontSize = '16px'
        btn.style.cursor = 'pointer'
        #~ btn.style.backgroundColor = btn.style.backgroundColor
        if letter.length == 1 then state.keyboardKeys.push btn   # record each key reference
        btn.onclick = ->
            switch letter
                when "Au sujet"
                    do -> await showAlert("Au sujet", "", "left",  AIDE.replace("{sad}", "\uD83D\uDE1E"))
                when "Nouveau mot"
                    new_word()
                when "Révéler mot"
                    reveal_word()
                else
                    btn.disabled = true
                    guess letter
        btn

    # Generate keys row-wise
    for row in rows
        rowDiv = document.createElement 'div'
        rowDiv.style.marginBottom = '5px'
        for letter in row
            rowDiv.appendChild createKey(letter)
        keyboard.appendChild rowDiv

# ----------------------------------------------------------------------
reveal = (letter) ->
    collator = new Intl.Collator('fr', { sensitivity: 'base' })

    revealed = state.revealedWord.split('')

    for ch, index in state.hiddenWord
        if collator.compare(ch, letter) == 0
            revealed[index] = state.hiddenWord[index]

    state.revealedWord = revealed.join('')
    update_labels()

# --------------------------------------
guess = (letter) ->
    if state.revealedWord is state.hiddenWord
        return

    if letter in state.triedLetters then return

    state.triedLetters.push letter

    beforeReveal = state.revealedWord
    reveal letter

    if state.revealedWord is beforeReveal
        state.failsCounter++
        update_labels()
        image_file = "pendu/pendu_#{state.failsCounter}.png"
        document.getElementById('theImage').src = image_file

    if state.failsCounter == 10
        state.revealedWord = state.hiddenWord
        update_labels()
        key.disabled = true for key in state.keyboardKeys
        await sleep 250
        do -> await showAlert("Hélas!", "info", "center",
            "Vous avez  perdu.<br><br>Le mot caché était: #{state.hiddenWord}")
    else if state.revealedWord is state.hiddenWord
        key.disabled = true for key in state.keyboardKeys
        await sleep 250
        do -> await showAlert("Bravo!", "info", "center", "Vous avez gagné.")

# --------------------------------------
reveal_word = ->
    if state.revealedWord is state.hiddenWord
        do -> await showAlert("Info", "", "center", "Le mot caché est déjà révélé.")
    else
        do ->
          result = await askConfirm("Attention", "question", 
            "Révéler le mot caché terminera cette partie.<br><br>Êtes-vous certain?")

          if result.isConfirmed
            # disable all alphabetic virtual keys
            key.disabled = true for key in state.keyboardKeys
            state.revealedWord = state.hiddenWord
            update_labels()

# --------------------------------------
generate_new_word = ->
    # pick a random word from words[] array defined in pendu_mots.js file
    state.hiddenWord = WORDS[Math.floor(Math.random() * WORDS.length)].toLowerCase()
    state.revealedWord = "*".repeat(state.hiddenWord.length)

    reveal "("
    reveal ")"
    reveal "-"

    state.gamesCounter++
    state.failsCounter = 0
    state.triedLetters = []

    # enable all alphabetic virtual keys
    key.disabled = false for key in state.keyboardKeys

    do -> await showAlert("Partie no: #{state.gamesCounter}", "", "center",
      "Mot caché de #{state.hiddenWord.length} lettres.")

    document.getElementById('theImage').src = "pendu/pendu_0.png"
    update_labels()

# --------------------------------------
new_word = ->
    if state.revealedWord is state.hiddenWord
        generate_new_word()
    else
        do ->
          result = await askConfirm("Attention", "question", 
            "Êtes-vous certain de commencer avec un nouveau mot?")

          if result.isConfirmed
            generate_new_word()

# --------------------- start game ----------------------

update_labels()
document.getElementById('theImage').src = "pendu/pendu_splash.png"
create_keyboard()

await sleep 250
new_word()
