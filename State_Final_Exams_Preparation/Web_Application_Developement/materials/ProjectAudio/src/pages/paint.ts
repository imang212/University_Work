import type {Audio, Dest} from '@inc/audio'
import {audioArticle} from '@inc/audio'
import {add, btn, el} from '@inc/tools'
import './paint.css'

let text = `
osc() --> gain() --> destination
on/off, 2D
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

  let trace = add(fCol, 'div', 'trace')
  let delTrace = () => {
    1 < trace.childElementCount && trace.removeChild(trace.firstChild!)
  }

  setInterval(delTrace, 22)

  trace.onmousemove = (event: MouseEvent) => {
    let rect = trace.getBoundingClientRect()
    let x = event.clientX - rect.left
    let y = event.clientY - rect.top

    let dot = add(trace, 'div', 'dot')
    dot.style.left = `${x}px`
    dot.style.top = `${y}px`

    while (trace.childElementCount > 60) delTrace()

    // callback
    gain.ramp(x / 300)
    osc.ramp(((300 - y) / 300) * 4000)
  }

  return fRow
}

export default (): HTMLElement => audioArticle(text, content)
