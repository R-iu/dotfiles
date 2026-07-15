const DEFAULT_TITLE = /^(New session|Child session) - \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/
const LOCAL_TIME_SUFFIX = / - \d{4}-\d{2}-\d{2} \d{2}:\d{2}$/

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

function formatTitleTimestamp(time) {
  const date = new Date(time)

  return [
    date.getFullYear(),
    "-",
    pad(date.getMonth() + 1),
    "-",
    pad(date.getDate()),
    " ",
    pad(date.getHours()),
    ":",
    pad(date.getMinutes()),
  ].join("")
}

function titleWithCreationTime(session) {
  if (LOCAL_TIME_SUFFIX.test(session.title)) return

  return `${session.title} - ${formatTitleTimestamp(session.time.created)}`
}

export default async ({ client }) => ({
  event: async ({ event }) => {
    if (event.type !== "session.created" && event.type !== "session.updated") return

    const session = event.properties.info
    const title = DEFAULT_TITLE.test(session.title)
      ? `${session.title.startsWith("Child session") ? "Child session" : "New session"} - ${formatLocalTimestamp(session.time.created)}`
      : titleWithCreationTime(session)

    if (!title) return

    await client.session.update({
      path: { id: session.id },
      query: { directory: session.directory },
      body: { title },
    })
  },
})
