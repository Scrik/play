app= angular.module 'app', ['ngRoute', 'ngResource', 'ngAnimate'], ($routeProvider) ->


    $routeProvider.when '/',
        templateUrl: 'partials/', controller: 'PlayCtrl'


    $routeProvider.when '/player',
        templateUrl: 'partials/player/', controller: 'PlayerCtrl'

    $routeProvider.when '/player/payments',
        templateUrl:'partials/player/payments/', controller:'PlayerPaymentsCtrl'

    $routeProvider.when '/player/payments/:paymentId',
        templateUrl: 'partials/player/payments/payment/', controller:'PlayerPaymentCtrl'


    $routeProvider.when '/store',
        templateUrl: 'partials/store/', controller: 'StoreCtrl'

    $routeProvider.when '/store/:server',
        templateUrl: 'partials/store/server/', controller: 'StoreServerCtrl'

    $routeProvider.when '/store/:server/:tag',
        templateUrl: 'partials/store/server/', controller: 'StoreServerCtrl'

    $routeProvider.when '/storage',
        templateUrl: 'partials/storage/', controller: 'StorageCtrl'

    $routeProvider.when '/storage/:server',
        templateUrl: 'partials/storage/server/', controller: 'StorageServerCtrl'


app.factory 'Player', ($resource) ->
    $resource '/api/v1/player/:action', {},
        get: {method:'get', timeout:7000}
        login: {method:'post', params:{action:'login'}}
        logout: {method:'post', params:{action:'logout'}}

app.factory 'PlayerPex', ($resource) ->
    $resource '/api/v1/player/pex', {},
        update: {method:'post'}


app.factory 'PlayerPayment', ($resource) ->
    $resource '/api/v1/player/payments/:paymentId', {paymentId:'@id'},
        query: {method:'GET', isArray:true, cache:true}
        create: {method:'POST'}


app.factory 'Subscription', ($resource) ->
    $resource '/api/v1/player/subscriptions/:subscriptionId/:action', {subscriptionId:'@id'},
        query: {method:'GET', isArray:true, cache:true}
        subscribe: {method:'POST', params:{action:'subscribe'}}



app.controller 'ViewCtrl', ($scope, $rootScope, $location, $window, Player, Server, $log) ->

    $rootScope.player= Player.get () ->
        $log.info 'игрок получен'

    $rootScope.logout= () ->
        $rootScope.player.$logout () ->
            $window.location.href= '/'

    $rootScope.servers= Server.query ->
        $log.info 'список серверов получен'

    $rootScope.getServerByName= (name) ->
        for server in $rootScope.servers
            return server if server.name == name

    $rootScope.store=
        servers: Server.query ->
            $log.info 'список серверов получен'


    $rootScope.dialog=
        overlay: null
        state: null

    $rootScope.showDialog= (type) ->
        $rootScope.dialog.state= 'none'
        $rootScope.dialog.overlay= type or true

    $rootScope.hideDialog= () ->
        $rootScope.dialog.overlay= null


    $rootScope.view=
        dialog:
            overlay: null
            state: null

    $rootScope.showViewDialog= (type) ->
        $rootScope.view.dialog.error= null
        $rootScope.view.dialog.state= 'none'
        $rootScope.view.dialog.overlay= type or true

    $rootScope.hideViewDialog= () ->
        $rootScope.view.dialog.overlay= null


    $scope.showPlayerPaymentDialog= () ->
        $scope.showDialog 'payment'


app.controller 'PlayCtrl', ($scope, $rootScope, $route, $q) ->
    $rootScope.route= 'play'
    $rootScope.server= null

    $scope.state= null

    promise= $q.all
        player: $rootScope.player.$promise
    promise.then () ->
            $scope.state= 'ready'
    ,   (error) ->
            $scope.state= 'error'
            $scope.error= error

    $scope.showContactDialog= () ->
        $scope.showDialog 'contact'


app.controller 'PlayerPaymentDialogCtrl', ($scope, $location, PlayerPayment, $log) ->
    $scope.payment= new PlayerPayment
    $scope.create= () ->
        $scope.dialog.state= 'busy'
        $scope.payment.$create (payment) ->
                $scope.dialog.state= 'done'
                $location.path "/player/payments/#{payment.id}"
                do $scope.hideDialog
        ,   () ->
                $scope.dialog.state= 'fail'


app.factory 'Contact', ($resource) ->
    $resource '/api/v1/player/messages', {},
        send: {method:'post'}

app.controller 'ContactDialogCtrl', ($scope, $route, Contact) ->
    $scope.contact= new Contact
    $scope.send= () ->
        $scope.dialog.state= 'busy'
        $scope.contact.$send (contact) ->
                $scope.dialog.state= 'done'
        ,   () ->
                $scope.dialog.state= 'none'



app.controller 'PlayerPaymentsCtrl', ($scope, $rootScope, PlayerPayment, $log) ->
    $rootScope.route= 'player'
    $scope.payments= PlayerPayment.query () ->
        $scope.state= 'ready'

app.controller 'PlayerPaymentCtrl', ($scope, $rootScope, $routeParams, PlayerPayment, $log) ->
    $rootScope.route= 'player'
    $scope.state= null
    $scope.payment= PlayerPayment.get $routeParams, () ->
        $scope.state= 'ready'



app.factory 'ServerStore', ($resource) ->
    $resource '/api/v1/servers/:serverId/store', {serverId:'@id'},
        get: {method:'GET', cache:true, params:{serverId:'@id'}}

app.factory 'ServerStoreItem', ($resource) ->
    $resource '/api/v1/store/servers/:serverId/items/:itemId/:action'
    ,   {serverId:'@serverId', itemId:'@itemId'}
    ,
        order: {method:'POST', params:{action:'order'}}

app.factory 'Server', ($resource) ->
    $resource '/api/v1/servers/:serverId', {serverId:'@id'},
        query: {method:'GET', cache:true, isArray:true}

app.factory 'ServerStorage', ($resource) ->
    $resource '/api/v1/servers/:serverId/storage', {serverId:'@id'},
        get: {method:'GET', cache:true, params:{serverId:'@id'}}

app.factory 'ServerStorageItem', ($resource) ->
    $resource '/api/v1/storage/servers/:serverId/items/:itemId/:action'
    ,   {serverId:'@serverId', itemId:'@itemId'}
    ,
        order: {method:'POST', params:{action:'order'}}



app.controller 'PlayerCtrl', ($scope, $rootScope, $route, Player, PlayerPex, $timeout) ->
    $rootScope.route= 'player'
    $rootScope.server= null

    $scope.player= Player.get () ->
            $scope.state= 'ready'
    ,   (err) ->
            $scope.state= 'error'
            $scope.error= err

    $scope.showPexDialog= () ->
        $scope.showViewDialog 'pex'

    $scope.updatePex= (data) ->
        PlayerPex.update data, () ->
                console.log 'обновилось'
        ,   () ->

    $scope.draw3d= true

    $scope.rX= -12
    $scope.rY= -12

    $scope.yes= () ->
        $scope.rX= '-36'
        $scope.rY= '0'
        $timeout ->
            $scope.$apply ->
                $scope.rX= '18'
                $scope.rY= '0'
                $timeout ->
                    $scope.$apply ->
                        $scope.rX= '-36'
                        $scope.rY= '0'
                        $timeout ->
                            $scope.$apply ->
                                $scope.rX= '-12'
                                $scope.rY= '-12'
                        ,   1000
                ,   1000
        ,   1000

    $scope.no= () ->
        $scope.rX= '0'
        $scope.rY= '36'
        $timeout ->
            $scope.$apply ->
                $scope.rX= '0'
                $scope.rY= '-36'
                $timeout ->
                    $scope.$apply ->
                        $scope.rX= '0'
                        $scope.rY= '18'
                        $timeout ->
                            $scope.$apply ->
                                $scope.rX= '-12'
                                $scope.rY= '-12'
                        ,   1000
                ,   1000
        ,   1000



app.directive 'bThreeNode', ($parse) ->
    ($scope, $e, $a) ->
        opts= $scope.$eval $a.bThreeNode
        $e.addClass 'b-three-node'


app.directive 'bThreeFace', ($parse) ->
    ($scope, $e, $a) ->
        opts= $scope.$eval $a.bThreeFace

        img= new Image
        img.src= opts.url
        img.onload= () ->
            scale= opts.scale

            srcCanvas= document.createElement 'canvas'
            srcCanvas.width= this.width;
            srcCanvas.height= this.height;
            srcCtx= srcCanvas.getContext '2d'
            srcCtx.drawImage this, 0, 0
            imageData= srcCtx.getImageData(
                opts.left, opts.top, opts.width, opts.height
            ).data
            dstCanvas= document.createElement 'canvas'
            dstCanvas.width= 8 * scale
            dstCanvas.height= 8 * scale
            dstCtx= dstCanvas.getContext '2d'

            x= 0
            y= 0

            offset= 0
            while offset < imageData.length

                r= imageData[offset++]
                g= imageData[offset++]
                b= imageData[offset++]
                a= imageData[offset++] / 100.0

                dstCtx.fillStyle= 'rgba(' + [r, g, b, a].join(',') + ')'
                dstCtx.fillRect x * scale, y * scale, scale, scale

                x++
                if x > 7
                    x= 0
                    y++

            url= dstCanvas.toDataURL 'image/png'
            $e.css 'background-image', "url(#{url})"

app.controller 'PlayerPexDialogCtrl', ($scope, PlayerPex) ->
    $scope.colors= [
        {token:'&0', hex:'#000000'}
        {token:'&1', hex:'#0000AA'}
        {token:'&2', hex:'#00AA00'}
        {token:'&3', hex:'#00AAAA'}
        {token:'&4', hex:'#AA0000'}
        {token:'&5', hex:'#AA00AA'}
        {token:'&6', hex:'#FFAA00'}
        {token:'&7', hex:'#AAAAAA'}
        {token:'&8', hex:'#555555'}
        {token:'&9', hex:'#5555FF'}
        {token:'&a', hex:'#55FF55'}
        {token:'&b', hex:'#55FFFF'}
        {token:'&c', hex:'#FF5555'}
        {token:'&d', hex:'#FF55FF'}
        {token:'&e', hex:'#FFFF55'}
        {token:'&f', hex:'#FFFFFF'}
    ]
    $scope.pex= new PlayerPex

    matchPrefixColor= (prefix) ->
        color= (prefix.match /^(&[0-9a-f]{1})/)[1]
        color

    matchPrefixTitle= (prefix) ->
        title= prefix.replace /&[0-9a-f]{1}/g, ''
        title= (title.match /([0-9A-Za-z]+)/)[1]
        title

    matchPlayerColor= (prefix) ->
        color= (prefix.match /(&[0-9a-f]{1})\s{1}$/)[1]
        color

    matchSuffixColor= (suffix) ->
        color= (suffix.match /^(&[0-9a-f]{1})/)[1]
        color

    matchPrefix= (pex, prefix) ->
        pex.prefixColor= matchPrefixColor prefix
        pex.prefixTitle= matchPrefixTitle prefix
        pex.playerColor= matchPlayerColor prefix

    matchSuffix= (pex, suffix) ->
        pex.suffixColor= matchSuffixColor suffix

    matchPrefix $scope.pex, $scope.player.pex.prefix
    matchSuffix $scope.pex, $scope.player.pex.suffix

    $scope.selectPrefixColor= (c) ->
        $scope.pex.prefixColor= c.token

    $scope.selectPlayerColor= (c) ->
        $scope.pex.playerColor= c.token

    $scope.selectSuffixColor= (c) ->
        $scope.pex.suffixColor= c.token

    $scope.$watch 'pex', (pex) ->
        prefix= ''
        if pex.prefixColor? and pex.playerColor?
            prefix= ''
            if pex.prefixTitle
                prefix= prefix + pex.prefixColor
                prefix= prefix + '[' + pex.prefixTitle + ']'
            prefix= prefix + pex.playerColor
            if pex.prefixTitle
                prefix= prefix + ' '
            prefix= prefix + $scope.player.name
        suffix= ''
        if pex.suffixColor?
            suffix= ''
            suffix= pex.suffixColor + ':'
        $scope.player.pex.title= prefix + suffix
    ,   true

    $scope.save= () ->
        $scope.view.dialog.state= 'busy'
        PlayerPex.save $scope.pex, (pex) ->
                matchPrefix $scope.pex, $scope.pex.prefix
                matchSuffix $scope.pex, $scope.pex.suffix
                $scope.player.pex.prefix= $scope.pex.prefix
                $scope.player.pex.suffix= $scope.pex.suffix
                $scope.view.dialog.state= 'done'
                do $scope.hideViewDialog
        ,   (err) ->
                $scope.view.dialog.state= 'fail'
                $scope.view.dialog.error= err


app.directive 'bPlayerPex', ($parse) ->

    renderTokenElement= (color) ->
        e= $ '<span ng-click="changePlayerColor()">'
        e.css 'color', color
        e

    renderToken= (e, token) ->
        switch token
            when '&0'
                e= renderTokenElement '#000000'
            when '&1'
                e= renderTokenElement '#0000AA'
            when '&2'
                e= renderTokenElement '#00AA00'
            when '&3'
                e= renderTokenElement '#00AAAA'
            when '&4'
                e= renderTokenElement '#AA0000'
            when '&5'
                e= renderTokenElement '#AA00AA'
            when '&6'
                e= renderTokenElement '#FFAA00'
            when '&7'
                e= renderTokenElement '#AAAAAA'
            when '&8'
                e= renderTokenElement '#555555'
            when '&9'
                e= renderTokenElement '#5555FF'
            when '&a'
                e= renderTokenElement '#55FF55'
            when '&b'
                e= renderTokenElement '#55FFFF'
            when '&c'
                e= renderTokenElement '#FF5555'
            when '&d'
                e= renderTokenElement '#FF55FF'
            when '&e'
                e= renderTokenElement '#FFFF55'
            when '&f'
                e= renderTokenElement '#FFFFFF'
            else
                e= $ '<span>' if not e
                e.append token
        e

    renderTitle= ($e, title, content) ->
        e= null
        title= title.split /(&[0-9a-f]{1})/
        for token in title
            e= renderToken e, token
            $e.append e
        e.append ' ' + content
        e

    return {
        restrict: 'A'

        controller: ($scope) ->
            $scope.changePlayerColor= () ->
                console.log 'changeColor'

        link: ($scope, $e, $a) ->
            getPlayerPex= $parse $a.bPlayerPex
            pex= getPlayerPex $scope

            content= $a.content or ''

            renderTitle $e, pex.title, content
            $scope.$watch $a.bPlayerPex, (pex) ->
                $e.html ''
                renderTitle $e, pex.title, content
            ,   true
    }



app.controller 'StoreCtrl', ($scope, $rootScope, $q, $log) ->
    $rootScope.route= 'store'
    $rootScope.server= null

    $scope.state= null
    promise= $q.all
        player: $rootScope.player.$promise
        servers: $rootScope.servers.$promise
    promise.then (resources) ->
            $scope.state= 'ready'
    ,   (error) ->
            $scope.state= 'error'
            $scope.error= error



app.factory '$thesaurus', ($log) ->
    $thesaurus=

        ### Собирает теги ###
        linkTags: (tags) ->
            #console.group('$thesaurus.linkTags', tags)

            idx= {}
            #console.group('Подготовить индекс...')
            for t in tags
                if not tag= idx[t.id]
                    tag= idx[t.id]= t
                continue if not tag.tags
                tag.tags= tag.tags.split ','
            #console.info '...индекс', idx
            #console.groupEnd()

            nodes= []
            #console.group('Собрать дерево...')
            for t in tags
                if not t.tags # корневой тег
                    nodes.push t
                if t.tags
                    #console.group('Собрать тег', t)
                    ids= t.tags
                    t.tags= []
                    for id in ids
                        continue if not tag= idx[id]
                        t.tags.push tag
                        if not tag.nodes
                            tag.nodes= []
                        tag.nodes.push t
                    #console.info '...тег', t
                    #console.groupEnd()
            #console.info '...дерево', nodes
            #console.groupEnd()
            nodes

        ### Собирает предметы тегов ###
        linkTagsItems: (tags, items) ->
            #console.group('$thesaurus.linkTagsItems', tags, items)

            idx= {}
            for t in tags
                if not tag= idx[t.id]
                    tag= idx[t.id]= t

            #console.group('Собрать списки...')
            for item in items
                continue if not item.tags
                ids= item.tags.split ','
                item.tags= []
                for id in ids
                    continue if not tag= idx[id]
                    if not tag.items
                        tag.items= []
                    tag.items.push item
                    item.tags.push tag
            #console.info '...списки', tags, items
            #console.groupEnd()
            items

app.controller 'StoreServerCtrl', ($scope, $rootScope, $q, $route, $routeParams, ServerStore, $log, $thesaurus, $location) ->
    $rootScope.route= 'store'

    $scope.state= null
    promise= $q.all
        player: $rootScope.player.$promise
        servers: $scope.store.servers.$promise
    promise.then (res) ->

            server= $rootScope.server= $rootScope.getServerByName $routeParams.server

            ServerStore.get
                serverId: server.id
            ,   (store) ->
                    $scope.store= store
                    $scope.state= 'ready'

                    # link tags
                    $scope.nodes= $thesaurus.linkTags $scope.store.tags

                    # link items tags
                    $scope.items= $thesaurus.linkTagsItems $scope.store.tags, $scope.store.items

                    # select tag
                    for tag in $scope.store.tags
                        if tag.name == $routeParams.tag
                            $scope.tag= tag
                            tag.selected= true
                            tag.expanded= true if tag.nodes and tag.nodes.length
                            if tag.tags and tag.tags.length
                                for t in tag.tags
                                    t.expanded= true

                            $scope.items= tag.items

                            $scope.search.q= tag.titleRuSingular

            ,   (err) ->
                    $scope.state= 'error'
                    $scope.error= err

    ,   (error) ->
            $scope.state= 'error'
            $scope.error= error

    $scope.search=
        q: ''
    $scope.searchClear= () ->
        $scope.search.q= ''
        if $routeParams.tag
            $location.path "/store/#{$routeParams.server}"

    $scope.search= (item) ->
        return item if not q= $scope.search.q

        q= do q.toLowerCase

        return item if 0 == item.material.indexOf q

        pattern= new RegExp q, 'i'

        return item if pattern.test item.titleRu
        return item if pattern.test item.titleEn

        return if not item.tags

        for tag in item.tags
            return item if pattern.test tag.titleRuSingular
            return item if pattern.test tag.titleEnSingular


app.controller 'StorageCtrl', ($scope, $rootScope, $q, $log) ->
    $rootScope.route= 'storage'
    $rootScope.server= null

    $scope.state= null
    promise= $q.all
        player: $rootScope.player.$promise
        servers: $rootScope.servers.$promise
    promise.then (resources) ->
            $scope.state= 'ready'
    ,   (error) ->
            $scope.state= 'error'
            $scope.error= error



app.controller 'StorageServerCtrl', ($scope, $rootScope, $q, $routeParams, ServerStorage, $log) ->
    $rootScope.route= 'storage'
    $scope.storage= null

    $scope.state= null
    promise= $q.all
        player: $rootScope.player.$promise
        servers: $rootScope.servers.$promise
    promise.then (resources) ->

            server= $rootScope.server= $rootScope.getServerByName $routeParams.server

            ServerStorage.get
                serverId: server.id
            ,   (storage) ->
                    $scope.storage= $rootScope.server.storage= storage
                    $scope.state= 'ready'
            ,   (err) ->
                    $scope.state= 'error'
                    $scope.error= err

    ,   (error) ->
            $scope.state= 'error'
            $scope.error= error

    $scope.search=
        q: ''
    $scope.searchClear= () ->
        $scope.search.q= ''




app.controller 'StoreServerItemCtrl', ($scope, $rootScope) ->

    $scope.showItemDetails= () ->
        $scope.view.dialog.item= $scope.item
        $scope.showViewDialog 'item'





app.filter 'EnchantmentLevel', () ->
    getEnchantmentDisplayLevel= (eid, level) ->
        switch eid
            when '0' # защита
                return 'I' if level < 22
                return 'II' if 21 < level < 33
                return 'III' if 32 < level < 44
                return 'IV' if 43 < level
            when '1' # огнестойкость
                return 'I' if level < 23
                return 'II' if 22 < level < 31
                return 'III' if 30 < level < 39
                return 'IV' if 38 < level
            when '2' # легкость
                return 'I' if level < 16
                return 'II' if 15 < level < 22
                return 'III' if 21 < level < 28
                return 'IV' if 27 < level
            when '3' # взрывоустойчивость
                return 'I' if level < 18
                return 'II' if 17 < level < 26
                return 'III' if 25 < level < 34
                return 'IV' if 33 < level
            when '4' # снарядостойкость
                return 'I' if level < 19
                return 'II' if 18 < level < 25
                return 'III' if 24 < level < 31
                return 'IV' if 30 < level
            when '5' # дыхание
                return 'I' if level < 41
                return 'II' if 40 < level < 51
                return 'III' if 50 < level
            when '6' # родство с водой
                return 'I'
            when '7' # шипы
                return 'I' if level < 61
                return 'II' if 60 < level < 81
                return 'III' if 80 < level
            when '16' # острота
                return 'I' if level < 22
                return 'II' if 21 < level < 33
                return 'III' if 32 < level < 44
                return 'IV' if 43 < level < 55
                return 'V' if 54 < level
            when '17' # небесная кара
                return 'I' if level < 26
                return 'II' if 25 < level < 34
                return 'III' if 33 < level < 42
                return 'IV' if 41 < level < 50
                return 'V' if 49 < level
            when '18' # бич членистоногих
                return 'I' if level < 26
                return 'II' if 25 < level < 34
                return 'III' if 33 < level < 42
                return 'IV' if 41 < level < 50
                return 'V' if 49 < level
            when '19' # отбрасывание
                return 'I' if level < 56
                return 'II' if 55 < level
            when '20' # аспект огня
                return 'I' if level < 61
                return 'II' if 60 < level
            when '21' # мародерство
                return 'I' if level < 66
                return 'II' if 65 < level < 75
                return 'III' if 74 < level
            when '48' # сила
                return 'I' if level < 17
                return 'II' if 16 < level < 27
                return 'III' if 26 < level < 37
                return 'IV' if 36 < level < 47
                return 'V' if 46 < level
            when '49' # ударная волна
                return 'I' if level < 38
                return 'II' if 38 < level
            when '50' # воспламенение
                return 'I'
            when '51' # бесконечность
                return 'I'
            when '32' # эффективность
                return 'I' if level < 52
                return 'II' if 51 < level < 62
                return 'III' if 61 < level < 72
                return 'IV' if 71 < level < 82
                return 'V' if 81 < level
            when '33' # шелковое касание
                return 'I'
            when '34' # неразрушимость
                return 'I' if level < 56
                return 'II' if 55 < level < 64
                return 'III' if 63 < level
            when '35' # удача
                return 'I' if level < 66
                return 'II' if 65 < level < 75
                return 'III' if 74 < level
    return (ench) ->
        return getEnchantmentDisplayLevel ench.id, ench.level


app.controller 'StoreServerItemDetailsCtrl', ($scope, $rootScope, ServerStoreItem) ->
    $scope.item= new ServerStoreItem angular.copy $scope.item
    $scope.itemPrice= $scope.item.price

    $scope.updatePrice= (price) ->
        $scope.item.price = $scope.item.price + price

    $scope.restrict= (item) ->
        return (enchantment) ->
            for ench in item.enchantments
                if enchantment.id == ench.id
                    return false
            return enchantment

    $scope.addEnchantment= (ench) ->
        for enchantment in $scope.item.enchantments
            if enchantment.id == ench.id
                return
        $scope.item.enchantments.push ench= angular.copy ench
        ench.level= ench.levelMin or 0
        ench.removable= true

    $scope.remEnchantment= (ench, price) ->
        i= $scope.item.enchantments.indexOf ench
        if i > -1
            $scope.item.enchantments.splice i, 1
            $scope.updatePrice 0 - price

    $scope.orderState= 'none'
    $scope.order= (item) ->
        $scope.orderState= 'pending'
        order=
            serverId: $scope.server.id
            itemId: item.id
            item:
                id: item.id
                amount: item.amount
                enchantments: item.enchantments
        ServerStoreItem.order order, () ->
                $scope.orderState= 'done'
        ,   (error) ->
                $scope.orderState= 'fail'




app.controller 'StoreServerItemDetailsEnchCtrl', ($scope, $rootScope) ->

    calcXpForLevel= (pLevel) ->
        if 17 > pLevel
            return 17 * pLevel
        if 16 < pLevel and 32 > pLevel
            return (1.5 * (pLevel * pLevel)) - (29.5 * pLevel) + 360
        if 31 < pLevel
            return (3.5 * (pLevel * pLevel)) - (151.5 * pLevel) + 2220

    calcXpForEnchantment= (eLevel, enchantability) ->
        pLevel= Math.floor eLevel - (1 + (enchantability / 2))
        return calcXpForLevel Math.max 1, pLevel

    $scope.level= 0
    $scope.levelMin= 0
    $scope.levelMax= 127

    $scope.xp= 0
    $scope.xpMin= 0

    $scope.price= 0

    if not $scope.ench.removable
        $scope.levelMin= $scope.ench.level
        $scope.level= $scope.levelMin
        $scope.xpMin= calcXpForEnchantment $scope.level, 10
        $scope.xp= $scope.xpMin
        #console.log 'чары входят в стоимость, levelMin: %d, xp: %d. Цена: %d', $scope.levelMin, $scope.xp, $scope.xp - $scope.xpMin
    else
        $scope.levelMin= $scope.ench.levelMin or 1
        $scope.level= $scope.ench.level or $scope.levelMin
        $scope.xp= calcXpForEnchantment $scope.level, 10
        #console.log 'чары не входят в стоимость, levelMin: %d, level: %d, xp: %d. Цена: %d', $scope.levelMin, $scope.level, $scope.xp, $scope.xp - $scope.xpMin

    $scope.levelMax= $scope.ench.levelMax

    $scope.$watch 'price', (newVal, oldVal) ->
        $scope.updatePrice newVal - oldVal

    $scope.$watch 'level', (level, o) ->
        if level < $scope.levelMin
            $scope.level= $scope.levelMin
            return
        $scope.xp= (calcXpForEnchantment level, 10) - $scope.xpMin
        #console.log 'обновился уровень чар: %d, разница xp: %d', level, $scope.xp
        $scope.ench.level= $scope.level

        $scope.price= $scope.xp * 0.03



app.directive 'bDropdown', () ->
    ($scope, $e, $a) ->
        $e.attr 'data-target', '#'
        do $e.dropdown



app.directive 'navTags', ($parse, $compile) ->
    directive=
        scope: false
        transclude: true

        template: """
            <li class='nav-tag' ng-repeat="tag in nodes" nav-tag="tag" ng-class="{expanded:tag.expanded&&deep, selected:tag.selected}"></li>
        """

        compile: (e, a, transclude) ->
            ($scope, $e, $a) ->
                $scope.nodes= $parse($a.navTags)($scope)

                $scope.deep= $parse($a.deep)($scope) or false

                transclude $scope, ($t) ->
                    $e.prepend $t

app.directive 'navTag', ($parse, $compile) ->
    directive=
        scope: false
        transclude: true
        template: """
            <a ng-href="#/store/{{server.name}}/{{node.name}}"> {{node.titleRuPlural}}</a>
        """

        controller: ($scope) ->
            $scope.expand= () ->
                $scope.node.expanded= true
                return false
            $scope.collapse= () ->
                $scope.node.expanded= false
                return false

        compile: (e, a, transclude) ->
            ($scope, $e, $a) ->
                $scope.node= $parse($a.navTag)($scope)
                if $scope.deep and angular.isArray $scope.node.nodes
                    $e.append $compile("""
                        <button class="nav-tag--act" ng-if="!node.expanded" ng-click="expand()"><i class="icon-angle-right"></i></button>
                        <button class="nav-tag--act" ng-if="!!node.expanded" ng-click="collapse()"><i class="icon-angle-down"></i></button>
                        <ul class='nav nav-list' nav-tags="node.nodes" ng-show="!!node.expanded"></ul>
                    """)($scope)
