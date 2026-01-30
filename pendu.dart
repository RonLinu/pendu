import 'package:web/web.dart'; // to install: dart pub add web
import 'dart:js_interop'; // needed for .toJS()
import 'dart:math'; // for Random()

import 'dialogs.dart';
import 'words.dart'; // loads ~17400 french words list

var RevealedWord = '';
var HiddenWord = '';
var GamesCounter = 0;
var FailsCounter = 0;

List<HTMLButtonElement> KeyboardKeys = [];
late HTMLButtonElement GameKey;

// -------------------------------------
void main() {
  createKeyboard();
  updateLabels();
}

// -------------------------------------
void play() {
  switch (GameKey.textContent) {
    case 'COMMENCER':
    case 'NOUVEAU MOT':
      generateNewWord();
    case 'RÉVÉLER MOT':
      revealWord();
  }
}

// -------------------------------------
void createKeyboard() {
  var footer = document.getElementById('footer');
  var keyboard = document.createElement('div') as HTMLElement;

  keyboard.style.marginTop = '10px';
  footer!.appendChild(keyboard);

  const rows = [
    ['A', 'B', 'C', 'D', 'E', 'F', 'G'],
    ['H', 'I', 'J', 'K', 'L', 'M', 'N'],
    ['O', 'P', 'Q', 'R', 'S', 'T', 'U'],
    ['V', 'W', 'X', 'Y', 'Z'],
    ['COMMENCER', 'AU SUJET']
  ];

  // ----- Local function to create one virtual keyboard button
  createButton(buttonName) {
    var btn = document.createElement('button') as HTMLButtonElement;

    // Button listener
    btn.onClick.listen((_) {
      switch (buttonName) {
        case 'COMMENCER':
          play();
        case 'AU SUJET':
          auSujet();
        default:
          btn.disabled = true;
          guess(buttonName);
      }
    });

    btn.textContent = buttonName;
    btn.style.cursor = 'pointer';
    btn.style.margin = '2px';
    btn.style.padding = '5px 14px';
    btn.style.fontSize = '16px';

    if (buttonName.length == 1) {
      KeyboardKeys.add(btn);
      btn.disabled = true;
    } else if (buttonName == 'COMMENCER') {
      GameKey = btn;
    }

    return btn;
  }

  // Generate virtual keyboard
  for (var row in rows) {
    var rowDiv = document.createElement('div') as HTMLElement;
    rowDiv.style.marginBottom = '5px';

    for (var buttonName in row) {
      var onebutton = createButton(buttonName);
      rowDiv.appendChild(onebutton);
    }
    keyboard.appendChild(rowDiv);
  }
}

// -------------------------------------
void generateNewWord() {
  do {
    HiddenWord = Words[Random().nextInt(Words.length)].toLowerCase();
  } while (HiddenWord.length > 20);

  RevealedWord = '*' * HiddenWord.length;

  reveal('(');
  reveal(')');
  reveal('-');

  GamesCounter++;
  FailsCounter = 0;

  // Enable all virtual alphabetic keys
  for (var key in KeyboardKeys) key.disabled = false;

  var image = document.getElementById('potence') as HTMLImageElement;
  image.src = 'resources/pendu_0.png';

  updateLabels();
  GameKey.textContent = 'RÉVÉLER MOT';

  showDialog("<center><b>Partie no. ${GamesCounter}</b></center><br>" +
      "Mot caché de ${HiddenWord.length} lettres");
}

// -------------------------------------
void updateLabels() {
  const s = '&nbsp;';
  var prefix = '<li><kbd style="font-size: 16px;">' + "${s}${s}${s}${s}";

  var labels = "${prefix}Partie no: ${GamesCounter}</kbd>";
  labels += "${prefix}Mot caché: ${RevealedWord}</kbd>";
  labels += "${prefix}${s}${s}Manqués: ${FailsCounter}</kbd>";

  var scores = document.getElementById('scores') as HTMLElement;
  scores.innerHTML = labels.toJS;
}

// -------------------------------------
String normalize(String letter) {
  const withDiacritics = 'àâäéèêëîïôöùûüÿç';
  const withoutDiacritics = 'aaaeeeeiioouuuyc';

  letter = letter.toLowerCase();

  var index = withDiacritics.indexOf(letter);

  if (index != -1) letter = withoutDiacritics[index];

  return letter;
}

// -------------------------------------
void reveal(String letter) {
  var normalizedLetter = normalize(letter);
  var revealed = RevealedWord.split('');

  for (int i = 0; i < HiddenWord.length; i++) {
    var ch = HiddenWord[i];
    if (normalize(ch) == normalizedLetter) revealed[i] = HiddenWord[i];
  }

  RevealedWord = revealed.join('');
}

// -------------------------------------
void revealWord() async {
  var msg =
      'Révéler le mot caché terminera cette partie.<br><br><center>Êtes-vous certain?</center>';

  var answer = await showDialog(msg, ok: 'Oui', cancel: 'Non');

  if (answer == 'ok') {
    // Disable all virtual alphabetic keys
    for (var btn in KeyboardKeys) btn.disabled = true;
    RevealedWord = HiddenWord;
    GameKey.textContent = 'NOUVEAU MOT';
    updateLabels();
  }
}

// -------------------------------------
void guess(letter) {
  var beforeReveal = RevealedWord;
  reveal(letter);
  updateLabels();

  if (RevealedWord == beforeReveal) {
    FailsCounter++;
    updateLabels();
    var image = document.getElementById('potence') as HTMLImageElement;
    image.src = "resources/pendu_${FailsCounter}.png";
  }

  if (FailsCounter == 10) {
    RevealedWord = HiddenWord;
    updateLabels();
    for (var btn in KeyboardKeys) btn.disabled = true;
    GameKey.textContent = 'NOUVEAU MOT';
    showDialog(
        "<center>Vous avez perdu!</center><br><center>Le mot caché était: <b>${HiddenWord}</b></center>");
  } else if (RevealedWord == HiddenWord) {
    for (var btn in KeyboardKeys) btn.disabled = true;
    GameKey.textContent = 'NOUVEAU MOT';
    showDialog("<center>Bravo!<center><br><center>Vous avez gagné.</center>");
  }
}

// -------------------------------------
void auSujet() {
  const msg = '''<center><b>Pendu © 2025 - RonLinu</b></center><br>
        Ce jeu bien connu consiste à deviner, une lettre à la fois,
        un mot caché qui est choisi au hazard parmi plus de
        17000 mots français.<br>
        <br>
        Si vous accumulez 10 échecs sans avoir trouvé un mot caché,
        vous perdez 😞<br>
        <br>
        Cliquer sur une lettre dévoile aussi toutes les lettres
        accentuées correspondantes.''';

  showDialog(msg);
}
