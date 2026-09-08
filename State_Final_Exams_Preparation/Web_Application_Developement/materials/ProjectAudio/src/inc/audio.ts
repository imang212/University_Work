import {add, article, d, del, el} from '@inc/tools'
import type {num, sec, str} from '@inc/types'

// a short time
let DT: sec = 0.03

// wait
type Wait = Promise<void>
// promise to wait
let wait = (dt: sec): Wait => new Promise<void>((resolve) => setTimeout(resolve, dt * 1000))

// ramping function
let ramp = (par: AudioParam, value: num, dt: num = DT): Wait => {
  let t = ctx.currentTime
  par.setValueAtTime(par.value, t)
  par.linearRampToValueAtTime(value, t + dt)
  return wait(dt)
}

// audio context
// Note: a warning "The AudioContext was not allowed to start .." is shown in the console.
// This is unavoidable, expected and not a bug.
let ctx = new window.AudioContext()

// output node + master volume control
export type Dest = AudioNode
let dest = ctx.createGain()
dest.connect(ctx.destination)

// audio off and on
let destOff = () => ramp(dest.gain, 0)
let destOn = () => ramp(dest.gain, 1)

// existing nodes, other than dest
let nodes: AudioNode[] = []

// re-initialize audio graph
let init = (): Wait =>
  new Promise<void>((resolve) => {
    // turn volume down
    destOff().then(() => {
      // empty audio graph
      nodes.forEach((node) => node.disconnect())
      nodes = []
      // resume audio context within user gesture, if suspended
      if ('suspended' == ctx.state) {
        let over = add(d.body, 'div', 'overlay')
        add(over, 'h2').innerText = 'Click to resume audio'
        over.onclick = () => {
          ctx
            .resume()
            .then(destOn)
            .then(() => {
              del(over)
              resolve()
            })
        }
      } else {
        // if not suspended, just resolve
        destOn().then(resolve)
      }
    })
  })

// node wrappers
type RampFun = (val: num, dt?: sec) => void
export type Oscillator = OscillatorNode & {ramp: RampFun}
export type Gain = GainNode & {ramp: RampFun}

// audio-managing object
let audio = {
  init,

  // unit generators / nodes
  osc: (type: OscillatorType, freq: num): Oscillator => {
    let osc = ctx.createOscillator() as Oscillator
    nodes.push(osc)
    osc.type = type
    osc.frequency.value = freq
    osc.ramp = (val: num, dt: num = 0.07) => ramp(osc.frequency, val, dt)
    return osc
  },

  gain: (amp: num): Gain => {
    let gain = ctx.createGain() as Gain
    nodes.push(gain)
    gain.gain.value = amp
    gain.ramp = (val: num, dt: num = 0.07) => ramp(gain.gain, val, dt)
    return gain
  },

  // pitches
  pitch: {
    A4: 440,
    Cs5: 550, // C#5
    E5: 660,
  },
}

export type Audio = typeof audio
export default audio

// creates a new article element with audio context
export let audioArticle = (
  text: str,
  content?: (audio: Audio, dest: Dest) => HTMLElement | void,
): HTMLElement => {
  let pre = el('pre')
  pre.textContent = text

  let art = article(pre)

  audio.init().then(() => {
    if (content) {
      let res = content(audio, dest)
      res && add(art, res)
    }
  })

  return art
}
