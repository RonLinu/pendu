var createKeyboard, game, generate_new_word, guess, play, reveal, reveal_word, showConfirmDialog, showDialog, updateLabels;

game = {
  revealedWord: '',
  hiddenWord: '',
  gamesCounter: '', // does not show zero
  failsCounter: '', // same
  keyboardKeys: [],
  gameKey: null
};


// --------------------------------------
createKeyboard = function() {
  var buttonName, createButton, footer, i, j, keyboard, len, len1, results, row, rowDiv, rows;
  footer = document.getElementById('footer');
  keyboard = document.createElement('div'); // keyboard container
  keyboard.style.marginTop = '10px';
  footer.appendChild(keyboard);
  // Define rows of alphabetic keys
  rows = [['A', 'B', 'C', 'D', 'E', 'F', 'G'], ['H', 'I', 'J', 'K', 'L', 'M', 'N'], ['O', 'P', 'Q', 'R', 'S', 'T', 'U'], ['V', 'W', 'X', 'Y', 'Z'], ['COMMENCER', 'AU SUJET']];
  // ----- Local function to create one virtual keyboard button
  createButton = function(buttonName) {
    var btn;
    btn = document.createElement('button');
    btn.onclick = function() {
      var aide;
      switch (buttonName) {
        case 'COMMENCER':
          return play();
        case 'AU SUJET':
          aide = document.getElementById("aide").innerHTML;
          return showDialog(aide);
        default:
          btn.disabled = true;
          return guess(buttonName);
      }
    };
    btn.textContent = buttonName;
    btn.style.cursor = 'pointer';
    btn.style.margin = '2px';
    btn.style.padding = '5px 14px';
    btn.style.fontSize = '16px';
    if (buttonName.length === 1) {
      game.keyboardKeys.push(btn); // record alpha key reference
      btn.disabled = true;
    } else if (buttonName === 'COMMENCER') {
      game.gameKey = btn; // record game key reference
    }
    return btn;
  };
// ----------------------------------

  // Generate virtual keyboard
  results = [];
  for (i = 0, len = rows.length; i < len; i++) {
    row = rows[i];
    rowDiv = document.createElement('div');
    rowDiv.style.marginBottom = '5px';
    for (j = 0, len1 = row.length; j < len1; j++) {
      buttonName = row[j];
      rowDiv.appendChild(createButton(buttonName));
    }
    results.push(keyboard.appendChild(rowDiv));
  }
  return results;
};

// --------------------------------------
updateLabels = function() {
  var labels, prefix, s, scores;
  scores = document.getElementById('scores');
  s = '&nbsp;';
  prefix = '<li><kbd style="font-size: 16px;">' + `${s}${s}${s}${s}`;
  labels = `${prefix}Partie no: ${game.gamesCounter}</kbd>`;
  labels += `${prefix}Mot caché: ${game.revealedWord}</kbd>`;
  labels += `${prefix}${s}${s}${s}Échecs: ${game.failsCounter}</kbd>`;
  return scores.innerHTML = labels;
};

// -------------------------------------
reveal = function(letter) {
  var ch, collator, i, index, len, ref, revealed;
  collator = new Intl.Collator('fr', {
    sensitivity: 'base'
  });
  revealed = game.revealedWord.split('');
  ref = game.hiddenWord;
  for (index = i = 0, len = ref.length; i < len; index = ++i) {
    ch = ref[index];
    if (collator.compare(ch, letter) === 0) {
      revealed[index] = game.hiddenWord[index];
    }
  }
  return game.revealedWord = revealed.join('');
};

// --------------------------------------
guess = function(letter) {
  var beforeReveal, i, image_file, j, key, len, len1, ref, ref1;
  beforeReveal = game.revealedWord;
  reveal(letter);
  updateLabels();
  if (game.revealedWord === beforeReveal) {
    game.failsCounter++;
    updateLabels();
    image_file = `resources/pendu_${game.failsCounter}.png`;
    document.getElementById('gallows').src = image_file;
  }
  if (game.failsCounter === 10) {
    game.revealedWord = game.hiddenWord;
    updateLabels();
    ref = game.keyboardKeys;
    for (i = 0, len = ref.length; i < len; i++) {
      key = ref[i];
      key.disabled = true;
    }
    game.gameKey.textContent = 'NOUVEAU MOT';
    return showDialog(`Vous avez perdu!<br><br>Le mot caché était: ${game.hiddenWord}`);
  } else if (game.revealedWord === game.hiddenWord) {
    ref1 = game.keyboardKeys;
    for (j = 0, len1 = ref1.length; j < len1; j++) {
      key = ref1[j];
      key.disabled = true;
    }
    game.gameKey.textContent = 'NOUVEAU MOT';
    return showDialog("Bravo!<br><br>Vous avez gagné.");
  }
};

// --------------------------------------
reveal_word = function() {
  var msg;
  msg = 'Révéler le mot caché terminera cette partie.<br><br>Êtes-vous certain?';
  return showConfirmDialog(msg).then(function(confirmed) {
    var i, key, len, ref;
    if (confirmed) {
      ref = game.keyboardKeys;
      for (i = 0, len = ref.length; i < len; i++) {
        key = ref[i];
        // disable all virtual alphabetical keys
        key.disabled = true;
      }
      game.revealedWord = game.hiddenWord;
      game.gameKey.textContent = 'NOUVEAU MOT';
      return updateLabels();
    }
  });
};

// --------------------------------------
generate_new_word = function() {
  var i, key, len, ref;
  // pick random word from WORDS[] array defined in pendu_mots.js
  while (true) {
    game.hiddenWord = window.WORDS[Math.floor(Math.random() * window.WORDS.length)].toLowerCase();
    // Avoid extra-long words (limit subject to change...)
    if (game.hiddenWord.length <= 20) {
      break;
    }
  }
  game.revealedWord = '*'.repeat(game.hiddenWord.length);
  reveal('(');
  reveal(')');
  reveal('-');
  game.gamesCounter++;
  game.failsCounter = '';
  ref = game.keyboardKeys;
  for (i = 0, len = ref.length; i < len; i++) {
    key = ref[i];
    // enable all virtual alphabetic keys
    key.disabled = false;
  }
  document.getElementById('gallows').src = 'resources/pendu_0.png';
  updateLabels();
  game.gameKey.textContent = 'RÉVÉLER MOT';
  return showDialog(`Partie no. ${game.gamesCounter}<br><br>` + `Mot caché de ${game.hiddenWord.length} lettres`);
};

// --------------------------------------
play = function() {
  switch (game.gameKey.textContent) {
    case 'COMMENCER':
    case 'NOUVEAU MOT':
      return generate_new_word();
    case 'RÉVÉLER MOT':
      return reveal_word();
  }
};

// --------------------------------------
showDialog = function(message) {
  var dialog, okBtn;
  dialog = document.createElement('dialog');
  dialog.innerHTML = `<p>${message}</p>
<center>
  <button id="okBtn">OK</button>
</center>`;
  document.body.appendChild(dialog);
  dialog.showModal();
  okBtn = dialog.querySelector('#okBtn');
  okBtn.style.fontSize = '16px';
  okBtn.style.padding = '5px 20px';
  return okBtn.onclick = function() {
    dialog.close();
    return dialog.remove();
  };
};


// --------------------------------------
showConfirmDialog = function(message) {
  var cancelBtn, dialog, okBtn;
  dialog = document.createElement('dialog');
  dialog.innerHTML = `<p>${message}</p>
<center>
  <button id="okBtn">Oui</button>
  <button id="cancelBtn">Non</button>
</center>`;
  // OK button
  okBtn = dialog.querySelector('#okBtn');
  okBtn.style.padding = '5px 20px';
  okBtn.style.fontSize = '16px';
  okBtn.onclick = function() {
    dialog.returnValue = 'ok';
    dialog.close();
    return dialog.remove();
  };
  // Cancel button
  cancelBtn = dialog.querySelector('#cancelBtn');
  cancelBtn.style.padding = '5px 20px';
  cancelBtn.style.fontSize = '16px';
  cancelBtn.onclick = function() {
    dialog.close();
    return dialog.remove();
  };
  document.body.appendChild(dialog);
  dialog.showModal();
  // Return Promise for async result
  return new Promise(function(resolve) {
    return dialog.onclose = function() {
      var result;
      result = dialog.returnValue;
      return resolve(result === 'ok');
    };
  });
};

(function() {  // **************************************
  return createKeyboard();
})();

//# sourceMappingURL=pendu.js.map
