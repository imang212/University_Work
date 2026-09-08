import type {Audio, Dest} from '@inc/audio'
import {audioArticle} from '@inc/audio'
import {btn, el} from '@inc/tools'

let text = `
osc() --> gain() --> destination
on/off
`

let content = (au: Audio, dest: Dest) => {
  let osc = au.osc('sine', au.pitch.Cs5)
  let gain = au.gain(0)
  osc.connect(gain)
  gain.connect(dest)
  osc.start()

  let fRow = el('f-row')
  btn(fRow, 'on', () => gain.ramp(0.3, 1))
  btn(fRow, 'off', () => gain.ramp(0, 1))
  return fRow
}

export default (): HTMLElement => audioArticle(text, content)
