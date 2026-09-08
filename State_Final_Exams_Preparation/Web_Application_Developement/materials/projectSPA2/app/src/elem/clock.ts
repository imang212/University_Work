import type {str} from '@inc/types'

let svgNS = 'http://www.w3.org/2000/svg'

let add = (parent: SVGElement, tag: str): SVGElement =>
  parent.appendChild(document.createElementNS(svgNS, tag)) as SVGElement

let setAttrs = (elem: SVGElement, attrs: {[key: str]: any}) => {
  for (let attr in attrs) elem.setAttribute(attr, attrs[attr])
}

let makeClock = (clock: SVGElement, divTime: HTMLElement, clockSize: number) => {
  let makeLine = (x1: number, y1: number, x2: number, y2: number) => {
    let line = add(clock, 'line')
    setAttrs(line, {x1, y1, x2, y2}) // !!!
    return line
  }

  let rotate = (line: SVGElement, deg: number) => {
    // +180 - so the clock is not upside down
    line.setAttribute('transform', `rotate(${deg + 180}, 0, 0)`)
  }

  let makeSecMark = (deg: number) => {
    let mark = makeLine(0, clockSize, 0, (clockSize * 9.5) / 10)
    setAttrs(mark, {'stroke-width': 2})
    rotate(mark, deg)
    return mark
  }

  let makeHourMark = (deg: number) => {
    let mark = makeLine(0, clockSize, 0, (clockSize * 9) / 10)
    rotate(mark, deg)
    return mark
  }

  for (let i = 0; i < 60; ++i) makeSecMark(i * 6)
  for (let i = 0; i < 12; ++i) makeHourMark(i * 30)

  let makeHand = (size: number, width: number) => {
    let hand = add(clock, 'line')

    setAttrs(hand, {
      'stroke-width': width,
      x1: 0,
      y1: -size / 5,
      x2: 0,
      y2: size,
    })

    return hand
  }

  let handSec = makeHand(130, 2)
  let handMin = makeHand(120, 4)
  let handHour = makeHand(100, 6)

  let hub = add(clock, 'circle')
  setAttrs(hub, {
    r: 10,
    fill: 'cyan',
  })

  let tick = () => {
    let now = new Date()
    divTime.textContent = now.toLocaleTimeString()

    let sec = now.getSeconds()
    rotate(handSec, sec * 6)

    let min = now.getMinutes()
    rotate(handMin, (min + sec / 60) * 6)

    let hour = now.getHours()
    rotate(handHour, (hour + min / 60 + sec / 3600) * 30)
  }

  tick()
  setInterval(tick, 1000)
}

export {makeClock}
