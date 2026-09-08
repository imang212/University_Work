import type {str, bol} from '@inc/types'

// shortcut
export let d = document

// toggles a class on an element
export let tgl = (el: Element, cls: str, force?: bol) => el.classList.toggle(cls, force)

// creates (if needed) and appends a new element to a parent element, optionally sets class
export let add = (
  parent: HTMLElement,
  child: HTMLElement | str,
  cls?: str,
): HTMLElement => {
  let el =
    child instanceof HTMLElement ? child : (d.createElement(child as str) as HTMLElement)
  parent.appendChild(el)
  if (cls) tgl(el, cls)
  return el
}

// creates a new article element
export let article = (): HTMLElement => d.createElement('article')
