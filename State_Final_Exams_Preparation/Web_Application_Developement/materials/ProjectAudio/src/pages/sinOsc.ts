import type {Audio, Dest} from '@inc/audio'
import {audioArticle} from '@inc/audio'

let text = `
osc() --> gain() --> destination
`

let content = (au: Audio, dest: Dest) => {
  let osc = au.osc('sine', au.pitch.A4)
  let gain = au.gain(0)
  osc.connect(gain)
  gain.connect(dest)
  osc.start()
  gain.ramp(0.6, 1)
}

export default (): HTMLElement => audioArticle(text, content)
