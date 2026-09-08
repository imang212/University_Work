import './clock.css'
import {article} from '@inc/tools'
import {makeClock} from '@elem/clock'

export default (): Element => {
  let art = article()
  art.innerHTML = `
    <svg width="300" height="300">
      <g
        id="clock"
        transform="translate(150 150)"
        stroke="black"
        stroke-width="4"
        stroke-linecap="round"
      >
        <circle r="140" fill="white" />
      </g>
    </svg>
    <div id="time"></div>
  `

  let clock = art.querySelector('#clock') as SVGElement
  let divTime = art.querySelector('#time') as HTMLElement
  makeClock(clock, divTime, 140)

  return art
}
