pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
contract GuessNumber is AccessControl,ReentrancyGuard{
    bool public status = true;
    uint public value;
    uint private submitted;
    bytes32 public constant HOST_ROLE = keccak256("HOST_ROLE");
    bytes32 public constant PLAYERS_ROLE = keccak256("PLAYERS_ROLE");
    bytes32 public nonceHash;
    bytes32 public nonceNumHash;
    uint16[] public playerGuessing;
    mapping(address => bool) public isGuessed;
    mapping(address => uint16) public player2guessing;
    address[] public players;



    modifier onlyPlayer(){
        require(hasRole(PLAYERS_ROLE, msg.sender),"is not Player");
        _;
    }
    modifier onlyHost(){
        require(hasRole(HOST_ROLE, msg.sender),"is not Host");
        _;
    }

    modifier concluded(){
        require(status,"The game has already concluded.");
        _;
    }

    //0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    //0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
    constructor(string memory _nonce,uint16 _nonceNum,address player1,address player2) payable{
        _setupRole(HOST_ROLE, msg.sender);
        _setupRole(PLAYERS_ROLE, player1);
        _setupRole(PLAYERS_ROLE, player2);
        players.push(player1);
        players.push(player2);
        nonceHash = keccak256(abi.encodePacked(_nonce));
        nonceNumHash = keccak256(abi.encodePacked(_nonce,_nonceNum));
        require(msg.value > 0,"Host should deposit some ether");
        value = msg.value;
    }

    // function setPlayers(address player) external onlyPlayer{
    //     _setupRole(PLAYERS_ROLE,player);
    // }


    function guess(uint16 number) external payable concluded onlyPlayer{
        require(msg.value == value,"The Player has not attached the same Ether value as the Host deposited.");
        require(number>=0 && number <1000,"Player inputs an invalid number");
        require(!isGuessed[msg.sender],"Player has already submitted a guessing");
        for(uint i; i < playerGuessing.length; i++){
            if(number == playerGuessing[i]){
                revert();
            }
        }
        playerGuessing.push(number);
        isGuessed[msg.sender] = true;
        player2guessing[msg.sender] = number;
        submitted++;
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function reveal(string memory nonce,uint16 number) external payable onlyHost concluded nonReentrant{
        require(submitted == 2,"not all player submitted their guessing");
        require(keccak256(abi.encodePacked(nonce)) == nonceHash,"invalid nonce");
        require(keccak256(abi.encodePacked(nonce,number)) == nonceNumHash,"invalid nonce+number");
        uint balance = address(this).balance;
        uint halfBalance = balance / 2;
        if(number >= 1000){
            status = false;
            payable(players[0]).call{value: halfBalance}("");
            payable(players[1]).call{value: balance-halfBalance}("");
        }else{
            //比较delta值,如果相同则平均分配
            uint delta1;
            uint delta2;
            if((number > player2guessing[players[0]])){
                delta1 = number - player2guessing[players[0]];
            }else{
                delta1 = player2guessing[players[0]] - number;
            }

            if((number > player2guessing[players[1]])){
                delta2 = number - player2guessing[players[1]];
            }else{
                delta2 = player2guessing[players[1]] - number;
            }
            status = false;
            if (delta1 == delta2){
                payable(players[0]).call{value: halfBalance}("");
                payable(players[1]).call{value: balance-halfBalance}("");
            }else if(delta1 > delta2){
                payable(players[1]).call{value: balance}("");
            }else{
                payable(players[0]).call{value: balance}("");
            }
        }

    }


}