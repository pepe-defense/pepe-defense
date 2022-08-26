export default fields =>
  Object.fromEntries(
    Object.entries(fields)
      .filter(([key]) => isNaN(key))
      .map(([key, value]) => {
        if (value._isBigNumber) return [key, value.toNumber()]
        return [key, value]
      })
  )
