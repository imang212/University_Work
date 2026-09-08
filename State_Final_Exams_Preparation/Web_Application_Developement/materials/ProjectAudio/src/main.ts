import {add, btn, d} from '@inc/tools'
import './style.css'

// app layout:
// ----------------------
// body
//   main
//     article (page)
//     (overlay to click to resume audio)
//   nav
//     buttons ...
let main = add(d.body, 'main')
let nav = add(d.body, 'nav')

// pages
let pages = ['hello', 'sinOsc', 'onOff', 'slide', 'slide2', 'paint', 'mod', 'clock']
let curPage = ''

// buttons to load pages
pages.forEach((pageName, i) => {
  let pageBtn = btn(nav, pageName, async () => {
    if (curPage != pageName) {
      let module = await import(`./pages/${(curPage = pageName)}.ts`)
      // clear and set the content
      main.innerHTML = ''
      main.appendChild(module.default())
    }
  })

  // load the first page
  if (0 == i) pageBtn.click()
})
