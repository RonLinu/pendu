# Written with CoffeeDelim

window.showDialog = (message, extras = {} ) ->
  {label='Ok', width='400'} = extras

  dialog = document.createElement('dialog')
  
  dialog.style.fontWeight = '400'
  dialog.style.fontFamily = 'Arial, sans-serif'
  if window.innerWidth > 400 then dialog.style.maxWidth = "#{width}px"
  
  dialog.style.borderRadius = '15px'
  dialog.style.overflow = 'hidden'            # optional, to clip content
  dialog.style.border = '1px solid #000'      #'1px solid #ccc'
  dialog.style.boxShadow = '0 4px 16px rgba(0,0,0,.2)'
  
  dialog.innerHTML = """
    #{message}
    <br>
    <center>
    <button id="okBtn">#{label}</button>
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
  end
  
  return dialog
end

# -----------------------------------------------------------------------------
window.showConfirmDialog = (message, extras = {} ) ->
  {leftLabel='Ok', rightLabel='Cancel'} = extras
  
  dialog = document.createElement('dialog')
  
  dialog.style.borderRadius = '15px'
  dialog.style.overflow = 'hidden'            # optional, to clip content
  dialog.style.border = '1px solid #000'      #'1px solid #ccc'
  dialog.style.boxShadow = '0 4px 16px rgba(0,0,0,.2)'
  
  dialog.innerHTML = """
    #{message}
    <br>
    <center>
    <button id="okBtn">#{leftLabel}</button>&ensp;&ensp;
    <button id="cancelBtn">#{rightLabel}</button>
    </center>
  """
  
  # OK button
  okBtn = dialog.querySelector('#okBtn')
  okBtn.style.padding = '2px 15px'
  okBtn.style.fontSize = '16px'
  
  okBtn.onclick = ->
    closeDialog leftLabel
  end
  
  # Cancel button
  cancelBtn = dialog.querySelector('#cancelBtn')
  cancelBtn.style.padding = '2px 15px'
  cancelBtn.style.fontSize = '16px'
  
  cancelBtn.onclick = ->
    closeDialog rightLabel
  end

  dialog.addEventListener 'cancel', (e) ->
    e.preventDefault()   # prevents the default close
    closeDialog 'escape'
  end

  closeDialog = (value) ->
    dialog.returnValue = value
    dialog.close()
    dialog.remove()
  end

  document.body.appendChild(dialog)
  dialog.showModal()

  # Return Promise for async result
  new Promise (resolve) ->
    dialog.onclose = ->
      result = dialog.returnValue
      resolve(result)
    end
  end

end
