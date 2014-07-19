db = require('levelup')('./data')
db = require('level-sublevel')(db)
db = require('level-ttl')(db)
module.exports = db
