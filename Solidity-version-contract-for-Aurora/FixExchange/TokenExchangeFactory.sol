pragma solidity ^0.8.0;
import '../interface/IERC20.sol';
import '../TransferHelper.sol';
contract tokenExchangeFactory{
    string public factoryName;
    string public factoryLogo;
    string public factoryIntroduction;
    uint public time;
    uint public releasePeriod;
    uint public closePeriod;
    mapping(uint=>info)fixedExchangeInfo;
    struct info{
        string information;
        uint rate;
        // uint time;
        // uint releasePeriod;
        // uint closePeriod;
    }
    string public appointExchangeInfo;
    struct Token1{
        address token;
        string  name;
        string  symbol;
        uint    price;
        uint   circulation;
    }
    Token1[] public list1;
    Token2[] public list2;
    //token2[] private list2;
    struct Token2{
        address  token;
        string   name;
        string   symbol;
        uint     price;
        uint     circulation;
    }
    struct userInfo{
        //uint id;
        uint amount;
        address user;
        uint time;
    }
    userInfo []public list3;
    uint public rate ;
    event SetExchangeRate(uint rates,uint _releasePeriod,uint _closePeriod);
    event AddToken(address _token1,string  _name1, string _symbol1,uint _price1,uint _circulation1,address _token2,string  _name2, string  _symbol2,uint _price2,uint _circulation2);
    event Deposit(address token2,uint amount);
    //event ExchangeToken(uint amount);
    constructor(string memory name ,string memory logo,string memory info) public {
        factoryName = name;
        factoryLogo=logo;
        factoryIntroduction=info;
    }
   

    function addToken(address _token1,string memory _name1, string memory _symbol1,uint _price1,uint _circulation1,address _token2,string memory _name2, string memory _symbol2,uint _price2,uint _circulation2)public{
        Token1 memory token1Info=Token1({
            token:_token1,
            name:_name1,
            symbol:_symbol1,
            price:_price1,
            circulation:_circulation1
        });
        list1.push(token1Info);
        Token2 memory token2Info=Token2({
            token:_token2,
            name:_name2,
            symbol:_symbol2,
            price:_price2,
            circulation:_circulation2
        });
        list2.push(token2Info);
        emit AddToken(_token1,_name1,_symbol1,_price1,_circulation1,_token2,_name2,_symbol2,_price2,_circulation2);
    }

    function setExchangeRate(uint number,uint rates,uint way ,uint price1,uint price2,uint _releasePeriod,uint _closePeriod )public{
        closePeriod=_closePeriod*2592000;
        releasePeriod=_releasePeriod*2592000;
        if (number==1){
            fixedExchangeInfo[number].information="fixed exchange rate";
            fixedExchangeInfo[number].rate=rates;
            rate=rates;
        }
        else if(number==2){
            appointExchangeInfo="the exchange rate of agreed amount";  
            if(way==1){
                rate =list1[0].price/list2[0].price;
            }
            if(way==2){
                rate=list1[0].price/price2;
            }
            if(way==3){
                rate=price1/list2[0].price;
            }
            if(way==4){
                rate=price1/price2;
            }
        }
        emit SetExchangeRate(rates,_releasePeriod,_closePeriod);
    }
    function deposit(address token2,uint amount)public{
        uint32 blockTime=uint32(block.timestamp % 2 ** 32);
        time=blockTime;
        //uint userBalance=IERC20(list2[1].token).balanceOf(msg.sender);
        require(amount<list2[0].circulation,"over circulation");
        //IERC20(list2[0].token).transfer(address(this),amount);
        TransferHelper.safeTransferFrom(token2 ,msg.sender,address(this), amount);
        userInfo memory userinfo=userInfo({
            //id: id,
            amount:amount,
            user:msg.sender,
            time:blockTime
        });
        list3.push(userinfo);
        emit Deposit(token2,amount);
    }
    function exchangeToken(address token,uint number,uint amount )public{
        //require(msg.sender==list3[0].user,"does not comply with exchange rules");
        uint32 blockTime=uint32(block.timestamp % 2 ** 32);
        require(blockTime>time+closePeriod,"Complete sealing period can not be extracted");
        require(amount<=list3[0].amount);
        if(number==1){
            //TransferHelper.safeTransferFrom(token,address(this),msg.sender,amount);
            IERC20(token).transfer(msg.sender,amount);
            list3[0].amount=list3[0].amount-amount;
        }
            if (number==2){
              uint amounts= list3[1].amount*(blockTime-time-closePeriod)/releasePeriod;
              require(amount<=amounts,"excess release limit");
                IERC20(token).transfer(msg.sender,amount);
                //TransferHelper.safeTransferFrom(token,address(this),msg.sender,amount);
                list3[0].amount=list3[0].amount-amount;
             }
             else if(number==3){
                uint amounts= list3[1].amount*((blockTime-time-closePeriod)/releasePeriod)*30;
                require(amount<=amounts,"excess release limit");
                IERC20(token).transfer(msg.sender,amount);
                TransferHelper.safeTransferFrom(token,address(this),msg.sender,amount);
                list3[0].amount=list3[0].amount-amount;
             }
             //emit ExchangeToken(list3[0].amount);
    }

}