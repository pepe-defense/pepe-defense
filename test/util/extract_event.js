import parse_struct from './parse_struct.js'

export default async tx_response =>
  tx_response
    .wait()
    .then(({ events }) => events)
    .then(([{ args }]) => parse_struct(args))
