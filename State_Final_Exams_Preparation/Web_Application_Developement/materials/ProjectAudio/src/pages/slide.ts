import type {Audio, Dest} from '@inc/audio'
import {audioArticle} from '@inc/audio'
import {add, btn, el} from '@inc/tools'

let text = `
osc() --> gain() --> destination
on/off, gain
`

let content = (au: Audio, dest: Dest) => {
  let osc = au.osc('sine', au.pitch.E5)
  let gain = au.gain(0)
  osc.connect(gain)
  gain.connect(dest)
  osc.start()

  let fRow = el('f-row')
  btn(fRow, 'on', () => gain.ramp(0.3, 1))
  btn(fRow, 'off', () => gain.ramp(0, 1))

  let slider = add(fRow, 'input', 'ptr') as HTMLInputElement
  slider.type = 'range'
  slider.value = '0'
  slider.min = '0'
  slider.max = '1'
  slider.step = '0.01'
  slider.oninput = () => gain.ramp(parseFloat(slider.value))

  return fRow
}

export default (): HTMLElement => audioArticle(text, content)
