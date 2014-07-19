db = require('levelup')('./data', valueEncoding: 'json')
db = require('level-sublevel')(db)
db = require('level-ttl')(db)
module.exports = db
db.userDb = db.sublevel('user')
