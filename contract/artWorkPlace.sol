
// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ArtworkPlace {
    address internal contractOwner;
    uint internal ArtworkLength = 0;
    address internal cUsdTokenAddress =  0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    struct Artwork {
        address payable owner;
        string name;
        string image;
        string shortHistory;
        string origin;
        uint price;
        uint sold;
    }

    mapping (uint => Artwork) internal artworks;
    
    	//CONSTRUCTOR
	constructor () payable  {
		contractOwner = msg.sender;
	}
    
    function createArtWork(
        string memory _name,
        string memory _image,
        string memory _shortHistory, 
        string memory _origin, 
        uint _price
    ) public {
        uint _sold = 0;
        artworks[ArtworkLength] = Artwork(
            payable(msg.sender),
            _name,
            _image,
            _shortHistory,
            _origin,
            _price,
            _sold
        );
        ArtworkLength++;
    }

    function viewArtWork(uint _index) public view returns (
        address payable,
        string memory, 
        string memory, 
        string memory, 
        string memory, 
        uint, 
        uint
    ) {
        return (
            artworks[_index].owner,
            artworks[_index].name, 
            artworks[_index].image, 
            artworks[_index].shortHistory, 
            artworks[_index].origin, 
            artworks[_index].price,
            artworks[_index].sold
        );
    }
 
    function buyArtWork(uint _index) public payable  {
         uint adjustedPrice = (artworks[_index].price * 95)/100;
         uint commissionPrice = (artworks[_index].price * 5)/100;

        require(msg.sender != artworks[_index].owner,"You cannot buy your own artwork");
        require(IERC20Token(cUsdTokenAddress).transferFrom(
             msg.sender,
             contractOwner,
             commissionPrice
        ), "Transfer to contract owner failed");
        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            artworks[_index].owner,
            adjustedPrice
          ),
          "Transfer to artwork owner failed."
        );
        artworks[_index].sold++;
    }

    function getContractBalance() public view returns (uint){
         return payable(address(this)).balance;
  }
    
    function getArtWorkLength() public view returns (uint) {
        return (ArtworkLength);
    }

    function editArtwork(
        uint _index,
        string memory _name,
        string memory _image,
        string memory _shortHistory, 
        string memory _origin, 
        uint _price )
        public {
        require(artworks[_index].owner == msg.sender,"Access denied!,only artwork owner can edit artwork");
        artworks[_index].name = _name;
        artworks[_index].image = _image;
        artworks[_index].shortHistory =  _shortHistory;
        artworks[_index].origin = _origin;
        artworks[_index].price = _price;
    }

    function removeArtwork( uint _index) public {
        require(artworks[_index].owner == msg.sender,"Access denied!,only artwork owner can remove artwork");
        delete artworks[_index];
           ArtworkLength--;

    }
}