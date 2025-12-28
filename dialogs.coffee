
showDialog = (message) ->
  dialog = document.createElement('dialog')

  dialog.style.fontWeight = '400'
  dialog.style.fontFamily = 'Arial, sans-serif'
  if window.innerWidth > 400 then dialog.style.maxWidth = '400px'

  dialog.style.borderRadius = '15px'
  dialog.style.overflow = 'hidden'            # optional, to clip content
  dialog.style.border = '1px solid #000'      #'1px solid #ccc'
  dialog.style.boxShadow = '0 4px 16px rgba(0,0,0,.2)'

  dialog.innerHTML = """
    #{message}
    <br>
    <center>
      <button id="okBtn">OK</button>
    </center>
  """

  document.body.appendChild(dialog)
  dialog.showModal()

  okBtn = dialog.querySelector('#okBtn')
  okBtn.style.fontSize = '16px'
  okBtn.style.padding = '2px 15px'

  okBtn.onclick = ->
    dialog.close()
    dialog.remove()

# --------------------------------------
showConfirmDialog = (message) ->
  dialog = document.createElement('dialog')
  
  dialog.style.borderRadius = '15px'
  dialog.style.overflow = 'hidden'            # optional, to clip content
  dialog.style.border = '1px solid #000'      #'1px solid #ccc'
  dialog.style.boxShadow = '0 4px 16px rgba(0,0,0,.2)'

  dialog.innerHTML = """
    #{message}
    <br>
    <center>
      <button id="okBtn">Oui</button>&ensp;&ensp;
      <button id="cancelBtn">Non</button>
    </center>
  """

  # OK button
  okBtn = dialog.querySelector('#okBtn')
  okBtn.style.padding = '2px 15px'
  okBtn.style.fontSize = '16px'

  okBtn.onclick = ->
    dialog.returnValue = 'ok'
    dialog.close()
    dialog.remove()

  # Cancel button
  cancelBtn = dialog.querySelector('#cancelBtn')
  cancelBtn.style.padding = '2px 15px'
  cancelBtn.style.fontSize = '16px'
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

