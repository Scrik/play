express= require 'express'
async= require 'async'

crypto= require 'crypto'
sha1= (string) ->
    hash= crypto.createHash 'sha1'
    hash.update string
    return hash.digest 'hex'

###
Методы API для работы c аутентифицированным игроком.
###
app= module.exports= do express
app.on 'mount', (parent) ->
    app.set 'maria', maria= parent.get 'maria'



    ###
    Отдает аутентифицированного игрока.
    ###
    app.get '/'
    ,   access

    ,   maria(
            app.get 'db'
        )

    ,   loadPlayer(
            maria.Player
        )

    ,   loadPlayerPex(
            maria.Player.Pex
        )

    ,   (req, res) ->

            res.json 200, req.player



    ###
    Обновляет данные pex аутентифицированного игрока.
    ###
    app.post '/pex'
    ,   access

    ,   maria(
            app.get 'db'
        )

    ,   updatePlayerPex(
            maria.Player.Pex
        )

    ,   (req, res) ->

            res.json 200, req.user.pex



    ###
    Аутентифицирует игрока.
    ###
    app.post '/login'

    ,   maria(
            app.get 'db'
        )

    ,   findPlayer(
            maria.Player
        )

    ,   authPlayer(
            maria.Player
        )

    ,   (req, res) ->

            res.json 200, req.player



    ###
    Деаутентифицирует игрока.
    ###
    app.post '/logout'
    ,   access

    ,   exitPlayer(
            maria.Player
        )

    ,   (req, res) ->

            res.json 200, true



    ###
    Регистрирует игрока.
    ###
    app.post '/register'

    ,   maria(
            app.get 'db'
        )

    ,   maria.transaction()

    ,   createPlayer(
            maria.Player
        )

    ,   maria.transaction.commit()

    ,   (req, res) ->

            res.json 201, req.player



    ###
    Обновляет аутентифицированного игрока.
    ###
    app.post '/'
    ,   access

    ,   maria(
            app.get 'db'
        )

    ,   maria.transaction()

    ,   updatePlayer(
            maria.Player
        )

    ,   maria.transaction.commit()

    ,   (req, res) ->

            res.json 200, req.player



access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next

loadPlayer= (Player) ->
    (req, res, next) ->
        playerId= req.user.id

        Player.get playerId, req.maria, (err, player) ->
            req.player= player or null

            if not err and not player
                err= 'player not found'

            return next err

loadPlayerPex= (PlayerPex) ->
    (req, res, next) ->
        PlayerPex.getByPlayerName req.player.name, req.maria, (err, pex) ->
            req.player.pex= pex

            if not err
                pex.title= ''
                if prefix= req.player.pex.prefix
                    pex.title= pex.title + prefix
                pex.title= pex.title + req.player.name
                if suffix= req.player.pex.suffix
                    pex.title= pex.title + suffix

            return next err

updatePlayerPex= (PlayerPex) ->
    (req, res, next) ->
        pex= new PlayerPex req.body

        if req.body.prefixColor? and req.body.playerColor?
            pex.prefix= ''
            if req.body.prefixTitle
                pex.prefix= pex.prefix + req.body.prefixColor
                pex.prefix= pex.prefix + '[' + req.body.prefixTitle + ']'
            pex.prefix= pex.prefix + req.body.playerColor
            if req.body.prefixTitle
                pex.prefix= pex.prefix + ' '
        else
            delete pex.prefix

        if req.body.suffixColor?
            pex.suffix= ''
            pex.suffix= req.body.suffixColor + ':'
        else
            delete pex.suffix

        PlayerPex.updateByPlayerName req.user.name, pex, req.maria, (err, pex) ->
            req.user.pex= pex

            return next err

findPlayer= (Player) ->
    (req, res, next) ->
        player= new Player req.body
        player.pass= sha1 req.body.pass or ''

        Player.getByNameAndPass player, req.maria, (err, player) ->
            req.player= player or null

            if not err and not player
                res.status 404
                err= 'player not found'

            return next err

authPlayer= (Player) ->
    (req, res, next) ->
        req.login req.player, (err) ->
            return next err

exitPlayer= (Player) ->
    (req, res, next) ->
        if req.user.name != req.body.name
            req.status 400
            err= 'cannot logout'

        if not err
            do req.logout

        return next err

createPlayer= (Player) ->
    (req, res, next) ->
        player= new Player req.body
        player.pass= sha1 req.body.pass or ''

        Player.create player, req.maria, (err, player) ->
            req.player= player or null

            if not err and not player.id
                res.status 400
                err= 'player create error'

            return next err

updatePlayer= (Player) ->
    (req, res, next) ->
        player= new Player req.body
        player.pass= sha1 req.body.pass or ''

        playerId= req.user.id

        Player.update playerId, player, req.maria, (err, player) ->
            req.player= player or null

            return next err
