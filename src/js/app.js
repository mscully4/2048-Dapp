App = {
    web3Provider: null,
    contracts: {},

    init: async function() {
        return await App.initWeb3();
    },

    initWeb3: async function() {
        if (typeof web3 !== 'undefined') {
        // If a web3 instance is already provided by Meta Mask.
            App.web3Provider = web3.currentProvider;
            web3 = new Web3(web3.currentProvider);
        } else {
            // Specify default instance if no web3 instance provided
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
            web3 = new Web3(App.web3Provider);
        }
        return App.initContract();
    },

    initContract: function() {
        $.getJSON("TwentyFortyEight.json", function(twentyfortyeight) {
            // Instantiate a new truffle contract from the artifact
            App.contracts.TwentyFortyEight = TruffleContract(twentyfortyeight);
            // Connect provider to interact with contract
            App.contracts.TwentyFortyEight.setProvider(App.web3Provider);


            return App.render();
        });
    },

    render: function() {
        // Load account data
        web3.eth.getCoinbase(function(err, account) {
            if (err === null) {
                App.account = account;
            }
        });
        App.contracts.TwentyFortyEight.deployed().then(function(instance) {
            chork = instance;
        })
        App.listenForEvents();
    },

    listenForEvents: function() {
        $(".new-game").click(function() {
            chork.startGame().then(function(){
                chork.gameStarted().watch(function(error, result) {
                    if (!error) {
                        App.loadBoard(result.args.gameId.toNumber());
                    } else {
                        console.log(error);
                    }
                })
            })
        });

        $(".load-game").click(function() {
            if ($(".game-id").val()) {
                App.loadBoard($(".game-id").val());
                $(".options").hide();
                $(".moves").show();
            }
        });

        $(".down").click(function() {
            App.moveDown();
        })

        $(".up").click(function() {
            App.moveUp();
        })

        $(".right").click(function() {
            App.moveRight();
        })

        $(".left").click(function() {
            App.moveLeft();
        })
    },

    loadBoard: function(id) {
        $("#game-number").text(id);
        App.contracts.TwentyFortyEight.deployed().then(function(instance) {
            instance.showBoard(id).then(function(array) {
                for (i=0; i<array.length; i++) {
                    if (array[i].toNumber()) {
                        $(`.item:nth-child(${i+1})`).text(array[i].toNumber());
                    } else {
                        $(`.item:nth-child(${i+1})`).text("-");
                    }
                }
            })
        })
                $(".options").hide();
                $(".moves").show();
    },

    updateBoard: function() {
        var gameId = $(".game-id").val();
        var items = $(".item")
        var array = []
        for (i=0; i<items.length; ++i) {
            if (items[i].innerHTML) {
                array.push(parseInt(items[i].innerHTML));
            } else {
                array.push(0);
            }
        }
        chork.updateBoard(gameId, array);
    },   

    moveUp: function() {
        chork.moveUp($(".game-id").val()).then(function() {
            $(".moves").hide();
            setTimeout(function() {
                App.loadBoard($(".game-id").val());
                $(".moves").show();
            }, 5000);
        })
    },

    moveDown: function () {
        chork.moveDown($(".game-id").val()).then(function() {
            $(".moves").hide();
            setTimeout(function() {
                App.loadBoard($(".game-id").val());
                $(".moves").show();
            }, 5000);
        })
    },

    moveLeft: function () {
        chork.moveLeft($(".game-id").val()).then(function() {
            $(".moves").hide();
            setTimeout(function() {
                App.loadBoard($(".game-id").val());
                $(".moves").show();
            }, 5000);
        })
    },

    moveRight: function() {
        chork.moveRight($(".game-id").val()).then(function() {
            $(".moves").hide();
            setTimeout(function() {
                App.loadBoard($(".game-id").val());
                $(".moves").show();
            }, 5000);
        })
    },

/*    moveDown: function() {
        var gameId = $(".game-id").val();
        var item;
        //traverse bottom up
        for (i=15; i>=0; --i) {
            item = $(".item")[i];
            //from any given tile, traverse bottom up again
            for (j=12+(i%4); j>i; j-=4) {
                //checks if the tiles directly below are empty and if so moves down accordingly
                if (!$(".item")[j].innerHTML) {
                    $(".item")[j].innerHTML = item.innerHTML;
                    item.innerHTML = "";
                } 
                //then check if a merge is possible and if so, executes the merge
                else if ($(".item")[j].innerHTML == item.innerHTML) {
                    //this makes sure that we don't jump tiles
                    if ((j-i == 4) || ((j-i) == 8 && !$(".item")[j-4].innerHTML) || ((j-i) == 12 && !$(".item")[j-4].innerHTML && !$(".item")[j-8].innerHTML)) {
                        $(".item")[j].innerHTML = parseInt(item.innerHTML) + parseInt($(".item")[j].innerHTML);
                        item.innerHTML = "";
                        break;
                    }
                }
            }
        }
        //App.updateBoard();
    },

    moveUp: function() {
        var gameId = $(".game-id").val();
        var item;
        for (i=0; i<16; ++i) {
            item = $(".item")[i];
            for (j=(i%4); j<i; j+=4) {
                if (!$(".item")[j].innerHTML) {
                    $(".item")[j].innerHTML = item.innerHTML;
                    item.innerHTML = "";
                    break;
                } else if ($(".item")[j].innerHTML == item.innerHTML) {
                    //this makes sure that we don't jump tiles
                    if ((i-j == 4) || ((i-j) == 8 && !$(".item")[j+4].innerHTML) || ((i-j) == 12 && !$(".item")[j+4].innerHTML && !$(".item")[j+8].innerHTML)) {
                        $(".item")[j].innerHTML = parseInt(item.innerHTML) + parseInt($(".item")[j].innerHTML);
                        item.innerHTML = "";
                        break;
                    }
                }
            }
        }item = $(".item")[i];
    },

    moveRight: function() {
        var gameId = $(".game-id").val();
        var item;
        for (i=15; i>=0 ; --i) {
            item = $(".item")[i];
            for (j=i-(i%4)+3; j>i; --j) {
                if (!$(".item")[j].innerHTML) {
                    $(".item")[j].innerHTML = item.innerHTML;
                    item.innerHTML = "";
                    break;
                } else if ($(".item")[j].innerHTML == item.innerHTML) {
                    if ((j-i == 1) || (j-i == 2 && !$(".item")[j-1].innerHTML) || (j-i == 3 && !$(".item")[j-1].innerHTML && !$(".item")[j-2].innerHTML)) {
                        $(".item")[j].innerHTML = parseInt(item.innerHTML) + parseInt($(".item")[j].innerHTML);
                        item.innerHTML = "";
                        console.log(4242334);
                        break;
                    }
                }
            }
        }
    },*/
}

$(function() {
  $(window).load(function() {
    App.init();
  });
});

