import type {Audio, Dest} from '@inc/audio'
import {audioArticle} from '@inc/audio'

let text = `
amplitude modulation
`

let content = (au: Audio, dest: Dest) => {
  let osc = au.osc('sawtooth', 1000)
  let lfo = au.osc('sine', 3)

  let gain = au.gain(0)

  osc.connect(gain)
  lfo.connect(gain.gain)

  gain.connect(dest)
  osc.start()
  lfo.start()
}

export default (): HTMLElement => audioArticle(text, content)
