import type {Audio, Dest} from '@inc/audio'
import {audioArticle} from '@inc/audio'
import {add, btn, el} from '@inc/tools'

let text = `
osc() --> gain() --> destination
on/off, gain, freq
`

let content = (au: Audio, dest: Dest) => {
  let osc = au.osc('sine', 0)
  let gain = au.gain(0)
  osc.connect(gain)
  gain.connect(dest)
  osc.start()

  let fRow = el('f-row')
  btn(fRow, 'on', () => gain.ramp(0.3, 1))
  btn(fRow, 'off', () => gain.ramp(0, 1))

  let fCol = add(fRow, 'f-col')

  let gainSlider = add(fCol, 'input', 'ptr') as HTMLInputElement
  gainSlider.type = 'range'
  gainSlider.value = '0'
  gainSlider.min = '0'
  gainSlider.max = '1'
  gainSlider.step = '0.01'
  gainSlider.oninput = () => gain.ramp(parseFloat(gainSlider.value))

  let freqSlider = add(fCol, 'input', 'ptr') as HTMLInputElement
  freqSlider.type = 'range'
  freqSlider.value = '0'
  freqSlider.min = '0'
  freqSlider.max = '10000'
  freqSlider.step = '1'
  freqSlider.oninput = () => osc.ramp(parseFloat(freqSlider.value))

  return fRow
}

export default (): HTMLElement => audioArticle(text, content)
