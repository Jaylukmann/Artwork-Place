
// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

//Creating ERC20 interface.
interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  //events for the frontend
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ArtworkPlace {
    //State variables:smart contract owner,the index of artwork $ the cUsd token address.
    address internal contractOwner;
    uint internal ArtworkLength = 0;
    address internal cUsdTokenAddress =  0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

   // Modellig each artwork.
    struct Artwork {
        address payable owner;
        string name;
        string image;
        string shortHistory;
        string origin;
        uint price;
        uint sold;
    }
     //Creating a key-value pair data type for each artwork.Accessing each through its index.
    mapping (uint => Artwork) internal artworks;
    
    	//CONSTRUCTOR:initializing the contract deployer as the owner.
	constructor () payable  {
		contractOwner = msg.sender;
	}
    
    //A setter function for creating each artwork.
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

     //A getter function for getting each artwork with its index.
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
 
    //Buying an artwork at 95% of cUsd to the owner and 5% cUsd to the contract owner.
    function buyArtWork(uint _index) public payable  {
        //Adjusting and sharing fund between arwork owner and smart contract owner
         uint adjustedPrice = (artworks[_index].price * 95)/100;
         uint commissionPrice = (artworks[_index].price * 5)/100;

        ///Sorry,you cannot buy your own artwork!
        require(msg.sender != artworks[_index].owner,"You cannot buy your own artwork");

        ///Transfer to contract owner failed
        require(IERC20Token(cUsdTokenAddress).transferFrom(
             msg.sender,
             contractOwner,
             commissionPrice
        ), "Transfer to contract owner failed");

         ///Transfer to artwork owner failed
        require(IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            artworks[_index].owner,
            adjustedPrice
          ),
          "Transfer to artwork owner failed."
        );
        artworks[_index].sold++;
    }
    
    //A getter for getting the balance of the smart contract.
    function getContractBalance() public view returns (uint){
         return payable(address(this)).balance;
  }
    //A getter for getting the total amount of artworks on the platform.
    function getArtWorkLength() public view returns (uint) {
        return (ArtworkLength);
    }
    //A function for changing the parameters of each artwork by the artwork owner alone.
    ///Access denied!,only artwork owner can edit artwork.
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

    //A function for deleting an artwork by the artwork owner alone.
     ///Access denied!,only artwork owner can remove artwork.
    function removeArtwork( uint _index) public {
        require(artworks[_index].owner == msg.sender,"Access denied!,only artwork owner can remove artwork");
        delete artworks[_index];
           ArtworkLength--;

    }
}