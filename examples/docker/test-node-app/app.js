// i have no idea what any of this means but ok, im not a backend dev...

const express = require('express')
const app = express()

app.get('/', (req, res) => {
    res.send('Hello World! This is a docker container.')
})
app.listen(3000, () => {
    console.log('Server ready')
})