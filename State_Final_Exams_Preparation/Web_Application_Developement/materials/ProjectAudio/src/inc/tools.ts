import type {str, bol} from '@inc/types'

// shortcut
export let d = document

// toggle the element class
export let tgl = (el: Element, cls: str, force?: bol) => el.classList.toggle(cls, force)

// if needed, create a new element
export let el = (elOrTag: HTMLElement | str): HTMLElement =>
  ('string' == typeof elOrTag ? d.createElement(elOrTag as str) : elOrTag) as HTMLElement

// append a new element to the parent, optional class
export let add = (parent: Element, child: HTMLElement | str, cls?: str): HTMLElement => {
  child = el(child)
  parent.appendChild(child)
  if (cls) tgl(child, cls, true)
  return child
}

// delete an element
export let del = (el: Element) => {
  el.parentElement?.removeChild(el)
}

// create a new article element
export let article = (content: HTMLElement): HTMLElement => {
  let art = d.createElement('article')
  add(art, content)
  return art
}

export let btn = (parent: Element, text: str, onclick: () => void): HTMLElement => {
  let btn = add(parent, 'x-btn', 'ptr')
  btn.textContent = text
  btn.onclick = onclick
  return btn
}
