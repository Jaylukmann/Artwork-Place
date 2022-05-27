
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

    // creating events
    event ArtCreated(address indexed owner, uint256 artId, string art_name);
    event ArtBought(address indexed buyer, address seller, uint256 artId, uint256 art_price);
    event ArtRemoved(address indexed owner, uint256 artId);

    modifier onlyOwnerAccess(uint256 _index) {
        require(artworks[_index].owner == msg.sender, "Access denied!,only artwork owner can access this function");
        _;
    }
    
    //CONSTRUCTOR:initializing the contract deployer as the owner.
	constructor () payable  {
		contractOwner = msg.sender;
	}
    
    //A setter function for creating each artwork.
    function createArtWork(
        uint _index,
        string memory _name,
        string memory _image,
        string memory _shortHistory, 
        string memory _origin, 
        uint _price
    ) public {
        if (artworks[_index].owner != msg.sender)
            ArtworkLength++;
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
        emit ArtCreated(msg.sender, ArtworkLength, _name);
    }

     //A getter function for getter each artwork with its index.
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
        uint adjustedPrice = (artworks[_index].price * 95)/100;
        uint commissionPrice = (artworks[_index].price * 5)/100;

        require(msg.sender != artworks[_index].owner,"You cannot buy your own artwork");
        // first buy the art
        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            artworks[_index].owner,
            adjustedPrice
          ),
          "Transfer to artwork owner failed."
        );
        // then give the commission
        require(IERC20Token(cUsdTokenAddress).transferFrom(
             msg.sender,
             contractOwner,
             commissionPrice
        ), "Transfer to contract owner failed");

        artworks[_index].sold++;
        emit ArtBought (msg.sender, artworks[_index].owner, _index, artworks[_index].price);
        artworks[_index].owner = payable(msg.sender); // assigning the new owner to the art after purchase
    }
    
    //A getter for getting the balance of the smart contract.
    function getContractBalance() public view returns (uint){
         return payable(address(this)).balance;
  }
    //A getter for getting the total amount of artwork on the platform.
    function getArtWorkLength() public view returns (uint) {
        return (ArtworkLength);
    }

    //A function for deleting an artwork by the artwork owner alone.
    function removeArtwork( uint _index) public onlyOwnerAccess(_index) {
        delete artworks[_index];
        ArtworkLength--;
        emit ArtRemoved(msg.sender, _index);
    }
}
