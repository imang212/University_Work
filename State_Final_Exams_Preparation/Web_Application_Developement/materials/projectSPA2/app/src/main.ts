import './style.css'
import {d, add} from '@inc/tools'

// app layout
let main = add(d.body, 'main')
let nav = add(d.body, 'nav')

// pages
let pages = ['hello', 'domTree', 'clock']

// build nav bar
for (let page of pages) {
  let div = add(nav, 'div', 'ptr')
  div.textContent = page

  // load pages on demand
  div.addEventListener('click', async () => {
    let module = await import(`./pages/${page}.ts`)
    main.innerHTML = ''
    main.appendChild(module.default())
  })

  // div.click() // load first page that arrives
}
