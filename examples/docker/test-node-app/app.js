// i have no idea what any of this means but ok, im not a backend dev...

const express = require('express')
const app = express()
const os = require('os')

app.get('/', (req, res) => {
    const hostname = os.hostname();
    res.send(`Hello World! Hostname is: ${hostname}\n`)
})
app.listen(3000, () => {
    console.log('Server ready')
})