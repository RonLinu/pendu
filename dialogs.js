window.showDialog = function(message, extras = {}) {
  var dialog, label, okBtn, width;
  ({label = 'Ok', width = '400'} = extras);
  dialog = document.createElement('dialog');
  dialog.style.fontWeight = '400';
  dialog.style.fontFamily = 'Arial, sans-serif';
  if (window.innerWidth > 400) {
    dialog.style.maxWidth = `${width}px`;
  }
  dialog.style.borderRadius = '15px';
  dialog.style.overflow = 'hidden'; // optional, to clip content
  dialog.style.border = '1px solid #000'; //'1px solid #ccc'
  dialog.style.boxShadow = '0 4px 16px rgba(0,0,0,.2)';
  dialog.innerHTML = `${message}
<br>
<center>
<button id="okBtn">${label}</button>
</center>`;
  document.body.appendChild(dialog);
  dialog.showModal();
  okBtn = dialog.querySelector('#okBtn');
  okBtn.style.fontSize = '16px';
  okBtn.style.padding = '2px 15px';
  okBtn.onclick = function() {
    dialog.close();
    return dialog.remove();
  };
  return dialog;
};

// -----------------------------------------------------------------------------
window.showConfirmDialog = function(message, extras = {}) {
  var cancelBtn, closeDialog, dialog, leftLabel, okBtn, rightLabel;
  ({leftLabel = 'Ok', rightLabel = 'Cancel'} = extras);
  dialog = document.createElement('dialog');
  dialog.style.borderRadius = '15px';
  dialog.style.overflow = 'hidden'; // optional, to clip content
  dialog.style.border = '1px solid #000'; //'1px solid #ccc'
  dialog.style.boxShadow = '0 4px 16px rgba(0,0,0,.2)';
  dialog.innerHTML = `${message}
<br>
<center>
<button id="okBtn">${leftLabel}</button>&ensp;&ensp;
<button id="cancelBtn">${rightLabel}</button>
</center>`;
  
  // OK button
  okBtn = dialog.querySelector('#okBtn');
  okBtn.style.padding = '2px 15px';
  okBtn.style.fontSize = '16px';
  okBtn.onclick = function() {
    return closeDialog(leftLabel);
  };
  
  // Cancel button
  cancelBtn = dialog.querySelector('#cancelBtn');
  cancelBtn.style.padding = '2px 15px';
  cancelBtn.style.fontSize = '16px';
  cancelBtn.onclick = function() {
    return closeDialog(rightLabel);
  };
  dialog.addEventListener('cancel', function(e) {
    e.preventDefault(); // prevents the default close
    return closeDialog('escape');
  });
  closeDialog = function(value) {
    dialog.returnValue = value;
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
      return resolve(result);
    };
  });
};
