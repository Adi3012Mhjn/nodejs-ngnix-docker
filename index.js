const express = require('express');
const nginx = require('nginx');

const app = express();
app.get('/', (req, res) => {
    res.send("Hello Aditi");
});

app.listen(3000,()=>{
    console.log("Listening on port 3000")
});
