pragma solidity ^0.4.18;
/**
* sellable contract should be inherited by any other contract that
* wants to provide a mechanism for selling its ownership to another account
*/
contract Sellable {

    //the owner of the contract
    address public owner;

    //current sale status
    bool public selling = false;

    //who is the selected buyer, if any
    //optional
    address public sellingTo;

    //how much ether (wei) the seller has asked the buyer to send
    uint public askingPrice;

    //
    //modifiers
    //

    //makes function required the called to be the owner of the contract
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    //add to functions that the owner wants to prevent being called  while the
    //contract is for sale
    modifier ifNotLocked {
        require(!selling);
        _;
    }

    event Transfer(uint _saleData, address _from, address _to, uint _salePrice);
    function Sellable() public {
        owner = msg.sender;
        Transfer(now, address(0), owner, 0);
    }

    /**
    * initiateSale is called by the owner of the contract to start
    * the sale process
    * @param _price is the asking for the sale
    * @param _to (OPTIONAL) is the address of the person that the owner
    * wants to sell the contract to. If set to 0x0, anyone can buy it.
    */

    function initiateSale(uint _price, address _to) onlyOwner public {
        require(_to != address(this) && _to != owner);
        require(!selling);

        selling = true;

        // set the target buyer, if specified
        sellingTo = _to;
        askingPrice = _price;
    }

    /**
    * cancelSale allows the owner to cancel the sale before someone buys
    * the contract.
    */
    function cancelSale() onlyOwner public {
        require(selling);

        // Reset sale variables
        resetSale();
    }

    /**
    * completeSale is called buy the specified buyer (or anyone if sellingTo)
    * was not set, to make the purchase
    * value sent must the asking price.
    */
    function completeSale(uint valued) public payable {
        require(selling);
        require(msg.sender != owner);
        require(msg.sender == sellingTo || sellingTo == address(0));
        require(valued == askingPrice);
        // swap ownership
        address prevOwner = owner;
        address newOwner = msg.sender;
        uint salePrice = askingPrice;

        owner = newOwner;

        // Transaction cleanup

        Transfer(now, prevOwner, newOwner, salePrice);
        resetSale();
    }

    //
    // internal functions
    //

    /**
    * resets the variables related to a sale process
    */

    function resetSale() internal {
        selling = false;
        sellingTo = address(0);
        askingPrice = 0;
    }
}