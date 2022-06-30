// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
//import "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract dork is ERC20PresetMinterPauser{
    constructor() ERC20PresetMinterPauser("dork","DK"){

    }
}

// interface IERC20 {
//     function totalSupply() external view returns (uint);

//     function balanceOf(address account) external view returns (uint);

//     function transfer(address recipient, uint amount) external returns (bool);

//     function allowance(address owner, address spender) external view returns (uint);

//     function approve(address spender, uint amount) external returns (bool);

//     function transferFrom(
//         address sender,
//         address recipient,
//         uint amount
//     ) external returns (bool);

//     event Transfer(address indexed from, address indexed to, uint value);
//     event Approval(address indexed owner, address indexed spender, uint value);
// }

contract DORK is IERC20{

    string public decimal="0";
    uint public override totalSupply;
    address public founder;
    mapping(address=>uint) public balances;
    mapping(address=>mapping(address=>uint)) allowed;

    function balanceOf(address tokenOwner) public view override returns(uint balance){
        return balances[tokenOwner];
}

    function transfer(address to,uint tokens) public virtual override returns(bool success){
        require(balances[msg.sender]>=tokens);
        balances[to]+=tokens; //balances[to]=balances[to]+tokens;
        balances[msg.sender]-=tokens;
        emit Transfer(msg.sender,to,tokens);
        return true;
}

    function approve(address spender,uint tokens) public override returns(bool success){
        require(balances[msg.sender]>=tokens);
        require(tokens>0);
        allowed[msg.sender][spender]=tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
}

    function allowance(address tokenOwner,address spender) public view override returns(uint noOfTokens){
        return allowed[tokenOwner][spender];
}

    function transferFrom(address from,address to,uint tokens) public virtual override returns(bool success){
        require(allowed[from][to]>=tokens);
        require(balances[from]>=tokens);
        balances[from]-=tokens;
        balances[to]+=tokens;
        return true;
    }   
}

contract ICO is DORK{

address public manager;
address payable public deposit;

uint tokenPrice=0.1 ether;

uint public cap=300 ether;

uint public raisedAmount;

uint public icoStart=block.timestamp;
uint public icoEnd=block.timestamp+3600; //1 hour=60*60 seconds;

uint public tokenTradeTime=icoEnd+3600;

uint public maxInvest=10 ether;
uint public minInvest=0.1 ether;

enum State{beforeStart,afterEnd,running ,halted}

State public icoState;

event Invest(address investor,uint value,uint tokens);

constructor(address payable _deposit){
    deposit=_deposit;
    manager=msg.sender;
    icoState=State.beforeStart;
}

modifier onlyManger(){
    require(msg.sender==manager);
    _;
}

function halt() public onlyManger{
    icoState=State.halted;
}
function resume() public onlyManger{
    icoState=State.running;
}
function changeDepositAddr(address payable newDeposit) public onlyManger{
    deposit=newDeposit;
}
function getState() public view returns(State){
    if(icoState==State.halted){
        return State.halted;
    }else if(block.timestamp<icoStart){
        return State.beforeStart;
    }else if(block.timestamp>=icoStart && block.timestamp<=icoEnd){
        return  State.running;
    }else{
        return State.afterEnd;
    }
}

function invest() payable public returns(bool){
    icoState=getState();
    require(icoState==State.running);
    require(msg.value >=minInvest && msg.value <=maxInvest);
    
    raisedAmount+=msg.value;
    
    require(raisedAmount<=cap);
    
    uint tokens=msg.value/tokenPrice; 
    balances[msg.sender]+=tokens;
    balances[founder]-=tokens;
    deposit.transfer(msg.value);
    
    emit Invest(msg.sender,msg.value,tokens);
    return true;
}

function burn() public returns(bool){
    icoState=getState();
    require(icoState==State.afterEnd);
    balances[founder]=0;
    return true;
}

function transfer(address to,uint tokens) public override returns(bool success){
    require(block.timestamp>tokenTradeTime);
    super.transfer(to,tokens);
    return true;
}

function transferFrom(address from,address to,uint tokens) public override returns(bool success){
    require(block.timestamp>tokenTradeTime);
    DORK.transferFrom(from,to,tokens);
    return true;
}

receive() external payable{
    invest();
}
}



