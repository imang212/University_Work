import {makeClock} from '@elem/clock'
import type {Audio, Dest} from '@inc/audio'
import {audioArticle} from '@inc/audio'
import {el} from '@inc/tools'
import type {num} from '@inc/types'
import './clock.css'

let content = (au: Audio, dest: Dest) => {
  // ticking
  let tick = au.gain(0)
  {
    let osc = au.osc('square', 800)
    osc.connect(tick)
    tick.connect(dest)
    osc.start()
  }

  // chirp
  let chirp = au.gain(0)
  {
    let carrier = au.osc('sine', 1000)
    let modulator = au.osc('sine', 9)
    let modGain = au.gain(100)

    modulator.connect(modGain)
    modGain.connect(carrier.frequency)
    carrier.connect(chirp)
    chirp.connect(dest)

    modulator.start()
    carrier.start()
  }

  let cbTick = (sec: num) => {
    if (0 == sec) {
      chirp.ramp(0.5, 0.5) // Ease-in
      chirp.ramp(0, 1) // Ease-out
    } else {
      tick.ramp(0, 0.7)
      tick.ramp(0.3, 0.71)
      tick.ramp(0, 0.72)
    }
  }

  let div = el('div')
  makeClock(div, 300, cbTick)
  return div
}
audioArticle
export default (): HTMLElement => audioArticle('', content)
