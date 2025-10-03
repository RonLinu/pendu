(function() {
  // https://ronlinu.github.io/pendu
  var askConfirm, create_keyboard, generate_new_word, guess, play, reveal, reveal_word, showAlert, show_labels, sleep, state;

  state = {
    revealedWord: '',
    hiddenWord: '',
    gamesCounter: 0,
    failsCounter: 0,
    keyboardKeys: [],
    gameKey: null
  };

  // --------------------------------------
  askConfirm = function(title, icon, message) {
    return Swal.fire({
      title: title,
      html: message,
      icon: icon,
      showCancelButton: true,
      confirmButtonText: 'Oui',
      cancelButtonText: 'Non',
      focusCancel: true,
      position: 'center'
    });
  };

  // --------------------------------------
  showAlert = function(title, icon, align, msg) {
    return new Promise(function(resolve) {
      return Swal.fire({
        title: title,
        html: `<div style='text-align: ${align}; font-size: 16px;'>${msg}</div>`,
        icon: icon,
        confirmButtonText: 'OK',
        position: align,
        animation: true,
        willClose: resolve
      });
    });
  };

  // --------------------------------------
  sleep = function(ms) {
    return new Promise(function(resolve) {
      return setTimeout(resolve, ms);
    });
  };

  // --------------------------------------
  show_labels = function() {
    var labels, prefix, s, scores;
    scores = document.getElementById('scores');
    s = '&nbsp;';
    prefix = '<li><kbd style="font-size: 16px;">' + `${s}${s}${s}${s}`;
    labels = `${prefix}Partie no: ${state.gamesCounter}</kbd></li>`;
    labels += `${prefix}Mot caché: ${state.revealedWord}</kbd></li>`;
    labels += `${prefix}${s}${s}${s}Échecs: ${state.failsCounter}</kbd></li>`;
    labels += `<li>${s}</li>`;
    return scores.innerHTML = labels;
  };

  // --------------------------------------
  create_keyboard = function() {
    var createKey, footer, i, j, keyboard, len, len1, letter, results, row, rowDiv, rows;
    footer = document.getElementById('footer');
    // Create keyboard container
    keyboard = document.createElement('div');
    keyboard.style.marginTop = '10px';
    footer.appendChild(keyboard);
    // Define rows of alphabet keys
    rows = [['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'], ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'], ['Z', 'X', 'C', 'V', 'B', 'N', 'M'], ['COMMENCER', 'AU SUJET']];
    // Function to create a key button
    createKey = function(letter) {
      var btn;
      btn = document.createElement('button');
      btn.textContent = letter;
      btn.style.cursor = 'pointer';
      if (letter.length === 1) {
        state.keyboardKeys.push(btn); // record alpha key reference
        btn.style.margin = '2px';
        btn.style.padding = '5px 14px';
        btn.style.fontSize = '16px';
        btn.disabled = true;
      } else if (letter === 'COMMENCER') {
        state.gameKey = btn; // record game key reference
        btn.style.margin = '5px';
        btn.style.padding = '5px 16px';
        btn.style.fontSize = '16px';
      } else {
        btn.style.margin = '5px';
        btn.style.padding = '5px 16px';
        btn.style.fontSize = '16px';
      }
      btn.onclick = function() {
        switch (letter) {
          case 'COMMENCER':
            return play();
          case 'AU SUJET':
            return showAlert('Au sujet de Pendu', '', 'left', AIDE);
          default:
            btn.disabled = true;
            return guess(letter);
        }
      };
      return btn;
    };
// Generate keys row-wise
    results = [];
    for (i = 0, len = rows.length; i < len; i++) {
      row = rows[i];
      rowDiv = document.createElement('div');
      rowDiv.style.marginBottom = '5px';
      for (j = 0, len1 = row.length; j < len1; j++) {
        letter = row[j];
        rowDiv.appendChild(createKey(letter));
      }
      results.push(keyboard.appendChild(rowDiv));
    }
    return results;
  };

  // ----------------------------------------------------------------------
  reveal = function(letter) {
    var ch, collator, i, index, len, ref, revealed;
    collator = new Intl.Collator('fr', {
      sensitivity: 'base'
    });
    revealed = state.revealedWord.split('');
    ref = state.hiddenWord;
    for (index = i = 0, len = ref.length; i < len; index = ++i) {
      ch = ref[index];
      if (collator.compare(ch, letter) === 0) {
        revealed[index] = state.hiddenWord[index];
      }
    }
    return state.revealedWord = revealed.join('');
  };

  // --------------------------------------
  guess = function(letter) {
    var beforeReveal, i, image_file, j, key, len, len1, ref, ref1;
    beforeReveal = state.revealedWord;
    reveal(letter);
    show_labels();
    if (state.revealedWord === beforeReveal) {
      state.failsCounter++;
      show_labels();
      image_file = `pendu/pendu_${state.failsCounter}.png`;
      document.getElementById('gallows').src = image_file;
    }
    if (state.failsCounter === 10) {
      state.revealedWord = state.hiddenWord;
      show_labels();
      ref = state.keyboardKeys;
      for (i = 0, len = ref.length; i < len; i++) {
        key = ref[i];
        key.disabled = true;
      }
      state.gameKey.textContent = 'NOUVEAU MOT';
      return showAlert('Vous avez perdu!', 'info', 'center', `Le mot caché était: ${state.hiddenWord}`);
    } else if (state.revealedWord === state.hiddenWord) {
      ref1 = state.keyboardKeys;
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        key = ref1[j];
        key.disabled = true;
      }
      state.gameKey.textContent = 'NOUVEAU MOT';
      return showAlert('Bravo!', 'info', 'center', "Vous avez gagné.");
    }
  };

  // --------------------------------------
  reveal_word = function() {
    return (async function() {
      var i, key, len, ref, result;
      result = (await askConfirm('Attention', 'question', 'Révéler le mot caché terminera cette partie.<br><br>Êtes-vous certain?'));
      if (result.isConfirmed) {
        ref = state.keyboardKeys;
        for (i = 0, len = ref.length; i < len; i++) {
          key = ref[i];
          // disable all virtual alphabetical keys
          key.disabled = true;
        }
        state.revealedWord = state.hiddenWord;
        state.gameKey.textContent = 'NOUVEAU MOT';
        return show_labels();
      }
    })();
  };

  // --------------------------------------
  generate_new_word = function() {
    var i, key, len, ref;
    // pick a random word from WORDS[] array defined in pendu_mots.js file
    while (true) {
      state.hiddenWord = WORDS[Math.floor(Math.random() * WORDS.length)].toLowerCase();
      // Avoid extra-long words (limit subject to change...)
      if (state.hiddenWord.length <= 20) {
        break;
      }
    }
    state.revealedWord = '*'.repeat(state.hiddenWord.length);
    reveal('(');
    reveal(')');
    reveal('-');
    state.gamesCounter++;
    state.failsCounter = 0;
    ref = state.keyboardKeys;
    for (i = 0, len = ref.length; i < len; i++) {
      key = ref[i];
      // enable all virtual alphabetic keys
      key.disabled = false;
    }
    showAlert(`Partie no. ${state.gamesCounter}`, '', 'center', `Mot caché de ${state.hiddenWord.length} lettres`);
    document.getElementById('gallows').src = 'pendu/pendu_0.png';
    show_labels();
    return state.gameKey.textContent = 'RÉVÉLER MOT';
  };

  // --------------------------------------
  play = function() {
    switch (state.gameKey.textContent) {
      case 'COMMENCER':
      case 'NOUVEAU MOT':
        return generate_new_word();
      case 'RÉVÉLER MOT':
        return reveal_word();
    }
  };

  // ------------------------ Get game ready ----------------------------
  show_labels();

  create_keyboard();

}).call(this);
