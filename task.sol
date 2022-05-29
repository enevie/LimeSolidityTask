// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.7;


contract Shop{

struct Product {
    uint id;
    string name;
    uint  quantity;
}

struct Order {
    address clientAddress;
    uint itemId;
    uint quantity;
}


mapping(uint => Product) private products;
mapping(string => bool) private addedProducts;

Order[] private orders;
address[] private historyOrders;

address private owner;
uint productsCount;
uint addressRegistryCount;

    constructor(){
        owner = msg.sender;
    }


 modifier onlyOwner() {
        require(owner == msg.sender, "Not invoked by the owner");
        _;
    }

function addProduct(string memory _product) public onlyOwner {
    require(!addedProducts[_product], "Product already added.");

    products[productsCount] = Product(productsCount, _product, 0);
    addedProducts[_product] = true;
    productsCount++;
}


function addQuantity(string memory _product, uint _quantity) public onlyOwner {
    require(addedProducts[_product], "Product not found!");

    for (uint i = 0; i < productsCount; i++) {
            if(keccak256(abi.encodePacked(products[i].name)) == keccak256(abi.encodePacked(_product))){
                    products[i].quantity = _quantity;
            }
        }
}

 function getAllProducts() public view returns (Product[] memory){
        Product[] memory ret = new Product[](productsCount);
        for (uint i = 0; i < productsCount; i++) {
            ret[i] = products[i];
        }
        return ret;
    }
  
  function buyProduct(uint _id, uint _requestQuantity) public {
     require(products[_id].quantity >= _requestQuantity , "Not enought quantity in the store.");
   
      for (uint i = 0; i < orders.length; i++) {
            if(orders[i].clientAddress == msg.sender){
                if(orders[i].itemId == _id) {
                    revert("The client already purchased this item.");
                }
            }
        }
     
            products[_id].quantity -= _requestQuantity;
            orders.push(Order(msg.sender,_id, _requestQuantity));
            historyOrders.push(msg.sender);
  }

  function getRegisteredAddresses() public view returns (address[] memory){
        return historyOrders;
    }


    function returnProduct(uint _id) public {
        require(block.timestamp > 100, "Your warranty is expired.");

             for (uint i = 0; i < orders.length; i++){
                    if(orders[i].clientAddress == msg.sender){
                        if(orders[i].itemId == _id){
                            products[_id].quantity += orders[i].quantity;
                             orders[i] = orders[orders.length - 1];
                             orders.pop();
                        }
                    }
                }
    }
}
