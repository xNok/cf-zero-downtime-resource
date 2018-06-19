const express = require("express")
const app = express()
const PORT = process.env.PORT || 3000

app.get("/", (req, res) => res.send("Hello World!"))
app.get("/good", (req, res) => res.status(200).json({ status: "UP" }))
app.get("/bad", (req, res) => res.status(503).json({ status: "DOWN" }))

app.listen(PORT, () => console.log(`Example app listening on port ${PORT}!`))
