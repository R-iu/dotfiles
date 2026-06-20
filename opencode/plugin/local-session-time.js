const DEFAULT_TITLE = /^(New session|Child session) - \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/

function pad(value, length = 2) {
  return String(value).padStart(length, "0")
}

function formatLocalTimestamp(time) {
  const date = new Date(time)
  const offsetMinutes = -date.getTimezoneOffset()
  const offsetSign = offsetMinutes >= 0 ? "+" : "-"
  const offsetAbsolute = Math.abs(offsetMinutes)

  return [
    date.getFullYear(),
    "-",
    pad(date.getMonth() + 1),
    "-",
    pad(date.getDate()),
    "T",
    pad(date.getHours()),
    ":",
    pad(date.getMinutes()),
    ":",
    pad(date.getSeconds()),
    ".",
    pad(date.getMilliseconds(), 3),
    offsetSign,
    pad(Math.floor(offsetAbsolute / 60)),
    ":",
    pad(offsetAbsolute % 60),
  ].join("")
}

export default async ({ client }) => ({
  event: async ({ event }) => {
    if (event.type !== "session.created") return

    const session = event.properties.info
    if (!DEFAULT_TITLE.test(session.title)) return


    const prefix = session.title.startsWith("Child session") ? "Child session" : "New session"
    const title = `${prefix} - ${formatLocalTimestamp(session.time.created)}`

    await client.session.update({
      path: { id: session.id },
      query: { directory: session.directory },
      body: { title },
    })
  },
})
