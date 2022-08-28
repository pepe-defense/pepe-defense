const MOB_BASE_LIFE = 3
const MOB_BASE_SPEED = 15
const MOB_BASE_AMOUNT = 10
const MOB_LIFE_MODIFIER = 161
const MOB_AMOUNT_MODIFIER = 119
const MOB_SPEED_MODIFIER = 116

function _curve(base, mod, wave) {
  return Math.floor((base * 100 * mod ** wave) / 100 ** (wave + 1))
}

Array.from({ length: 20 }).forEach((_, i) => {
  const wave = i + 1
  const count = `${_curve(MOB_BASE_AMOUNT, MOB_AMOUNT_MODIFIER, wave)}`.padEnd(
    3,
    ' '
  )
  const life = `${_curve(MOB_BASE_LIFE, MOB_LIFE_MODIFIER, wave)}`.padEnd(
    5,
    ' '
  )
  const speed = `${_curve(MOB_BASE_SPEED, MOB_SPEED_MODIFIER, wave)}`.padEnd(
    3,
    ' '
  )
  const wave_string = `${wave}`.padStart(2, ' ')
  console.log(
    `WAVE[${wave_string}] count: ${count} | life: ${life} | speed ${speed}`
  )
})
