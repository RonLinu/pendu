/*
Jeu de Pendu en francais
*/
var createKeyboard, game, generate_new_word, guess, play, reveal, reveal_word, updateLabels;

game = {
  revealedWord: '',
  hiddenWord: '',
  gameCounter: '', // empty string, does not show as zero
  failCounter: '', // same
  keyboardKeys: [],
  gameKey: null
};

// -------------------------------------- 
createKeyboard = function() {
  var buttonName, createButton, footer, i, j, keyboard, len, len1, results, row, rowDiv, rows;
  footer = document.getElementById('footer');
  keyboard = document.createElement('div'); // keyboard container
  keyboard.style.margin = '10px';
  footer.appendChild(keyboard);
  
  // Define rows of alphabetic keys 
  rows = [['A', 'B', 'C', 'D', 'E', 'F', 'G'], ['H', 'I', 'J', 'K', 'L', 'M', 'N'], ['O', 'P', 'Q', 'R', 'S', 'T', 'U'], ['V', 'W', 'X', 'Y', 'Z'], ['COMMENCER', 'AU SUJET']];
  
  // ----- Local function to create one virtual keyboard button 
  Object(createButton = function(buttonName) {
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
  });

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
  var labels, prefix, scores, sp;
  scores = document.getElementById('scores');
  sp = '&nbsp;';
  prefix = '<li><kbd style="font-size: 16px;">' + `${sp}${sp}${sp}${sp}`;
  labels = `${prefix}Partie no: ${game.gameCounter}</kbd>`;
  labels += `${prefix}Mot caché: ${game.revealedWord}</kbd>`;
  labels += `${prefix}${sp}${sp}Manqués: ${game.failCounter}</kbd>`;
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
    game.failCounter++;
    updateLabels();
    image_file = `resources/pendu_${game.failCounter}.png`;
    document.getElementById('gallows').src = image_file;
  }
  if (game.failCounter === 10) {
    game.revealedWord = game.hiddenWord;
    updateLabels();
    ref = game.keyboardKeys;
    for (i = 0, len = ref.length; i < len; i++) {
      key = ref[i];
      key.disabled = true;
    }
    game.gameKey.textContent = 'NOUVEAU MOT';
    return showDialog(`<center>Vous avez perdu!</center><br><center>Le mot caché était: ${game.hiddenWord}</center>`);
  } else if (game.revealedWord === game.hiddenWord) {
    ref1 = game.keyboardKeys;
    for (j = 0, len1 = ref1.length; j < len1; j++) {
      key = ref1[j];
      key.disabled = true;
    }
    game.gameKey.textContent = 'NOUVEAU MOT';
    return showDialog("<center>Bravo!<center><br><center>Vous avez gagné.</center>");
  }
};


// -------------------------------------- 
reveal_word = async function() {
  var answer, i, key, len, msg, ref;
  msg = 'Révéler le mot caché terminera cette partie.<br><br><center>Êtes-vous certain?</center>';
  answer = (await showConfirmDialog(msg, {
    leftLabel: 'Oui',
    rightLabel: 'Non'
  }));
  
  // disable all virtual alphabetical keys if revealed 
  if (answer === 'Oui') {
    ref = game.keyboardKeys;
    for (i = 0, len = ref.length; i < len; i++) {
      key = ref[i];
      key.disabled = true;
    }
    game.revealedWord = game.hiddenWord;
    game.gameKey.textContent = 'NOUVEAU MOT';
    return updateLabels();
  }
};


// -------------------------------------- 
generate_new_word = function() {
  var i, key, len, ref;
  while (true) {
    // pick random word from WORDS[] array defined in pendu_mots.js 
    game.hiddenWord = window.WORDS[Math.floor(Math.random() * window.WORDS.length)].toLowerCase();
    if (game.hiddenWord.length <= 20) {
      break;
    }
  }
  game.revealedWord = '*'.repeat(game.hiddenWord.length);
  reveal('(');
  reveal(')');
  reveal('-');
  game.gameCounter++;
  game.failCounter = '';
  ref = game.keyboardKeys;
  for (i = 0, len = ref.length; i < len; i++) {
    key = ref[i];
    
    // enable all virtual alphabetic keys 
    key.disabled = false;
  }
  document.getElementById('gallows').src = 'resources/pendu_0.png';
  updateLabels();
  game.gameKey.textContent = 'RÉVÉLER MOT';
  return showDialog(`<center>Partie no. ${game.gameCounter}<center><br>` + `<center>Mot caché de ${game.hiddenWord.length} lettres</center>`);
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

(function() {  
  // ************************************** 
  var prefix, scores;
  createKeyboard();
  scores = document.getElementById('scores');
  prefix = '<li><kbd style="font-size: 16px;">&nbsp;</kbd></li>';
  return scores.innerHTML = prefix + prefix + prefix;
})();
