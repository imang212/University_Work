import {add, article} from '@inc/tools'

export default (): HTMLElement => {
  let art = article()

  let h1 = add(art, 'h1')
  h1.textContent = 'Hello, World!'

  return art
}
