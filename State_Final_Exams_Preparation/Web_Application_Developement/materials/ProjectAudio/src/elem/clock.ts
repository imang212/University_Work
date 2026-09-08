import {d} from '@inc/tools'
import type {num, str} from '@inc/types'

/* eslint-disable-next-line @typescript-eslint/no-explicit-any */
type Attrs = {[key: str]: any}

export let addSvg = (el: Element, tag: str, attrs: Attrs = {}): SVGElement => {
  let svgEl = el.appendChild(d.createElementNS('http://www.w3.org/2000/svg', tag))
  setAttrs(svgEl, attrs)
  return svgEl
}

let setAttrs = (el: SVGElement, attrs: Attrs) => {
  for (let attr in attrs) el.setAttribute(attr, attrs[attr])
}

let makeClock = (container: HTMLElement, size: num, cbTick: (sec: num) => void) => {
  let svg = addSvg(container, 'svg') as SVGSVGElement
  svg.style.width = svg.style.height = `${size}px`

  let g = addSvg(svg, 'g', {
    transform: 'translate(150 150)',
    stroke: 'black',
    'stroke-width': '4',
    'stroke-linecap': 'round',
  })

  let r = size / 2 - 10

  // clock face
  addSvg(g, 'circle', {
    r,
    fill: 'white',
  })

  let makeLine = (x1: num, y1: num, x2: num, y2: num, attrs: Attrs = {}) =>
    addSvg(g, 'line', {x1, y1, x2, y2, ...attrs})

  let rotate = (line: SVGElement, deg: num) => {
    // +180 - so the clock is not upside down
    line.setAttribute('transform', `rotate(${deg + 180}, 0, 0)`)
  }

  let makeSecMark = (deg: num) => {
    let mark = makeLine(0, r, 0, r - 10, {'stroke-width': 2})
    if (354 == deg) setAttrs(mark, {stroke: 'red', 'stroke-width': 4})
    rotate(mark, deg)
    return mark
  }

  let makeHourMark = (deg: num) => {
    let mark = makeLine(0, r, 0, r - 15, {'stroke-width': 3})
    rotate(mark, deg)
    return mark
  }

  for (let i = 0; i < 12; ++i) makeHourMark(i * 30)
  for (let i = 0; i < 60; ++i) makeSecMark(i * 6)

  let makeHand = (size: num, width: num) => {
    let hand = addSvg(g, 'line', {
      'stroke-width': width,
      x1: 0,
      y1: -size / 5,
      x2: 0,
      y2: size,
    })

    hand.style.transition = 'transform .7s ease-in-out'

    return hand
  }

  let handSec = makeHand(126, 2)
  let handMin = makeHand(120, 4)
  let handHour = makeHand(100, 6)

  // hub
  addSvg(g, 'circle', {
    r: 8,
    'stroke-width': 3,
    fill: 'gold',
  })

  let tick = () => {
    let now = new Date()

    let sec = now.getSeconds()
    rotate(handSec, sec * 6)

    let min = now.getMinutes()
    rotate(handMin, (min + sec / 60) * 6)

    let hour = now.getHours()
    rotate(handHour, (hour + min / 60 + sec / 3600) * 30)

    cbTick(sec)
  }

  tick()
  setInterval(tick, 1000)
}

export {makeClock}
