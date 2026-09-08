import './domTree.css'
import {d, add, tgl, article} from '@inc/tools'

const domTree = (el: HTMLElement, ol: HTMLElement) => {
  let li = add(ol, 'li', 'ptr')
  li.textContent = el.tagName

  li.addEventListener('click', (e) => {
    e.stopPropagation()
    let target = e.target as HTMLElement

    if ('LI' == target.tagName) {
      tgl(target, 'active')
      // nested ol
      let ol = target.querySelector('ol')
      if (ol) tgl(ol, 'hidden')
    }
  })

  let children = Array.from(el.children)
  if (children) {
    let ol = add(li, 'ol', 'hidden')
    children.forEach((child) => child instanceof HTMLElement && domTree(child, ol))
  }
}

export default (): HTMLElement => {
  let art = article()

  let ol = add(art, 'ol')
  domTree(d.body, ol)

  return art
}
