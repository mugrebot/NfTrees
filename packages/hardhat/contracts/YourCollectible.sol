pragma solidity >=0.6.0 <0.7.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import 'base64-sol/base64.sol';

import './HexStrings.sol';
import './ToColor.sol';
//learn more: https://docs.openzeppelin.com/contracts/3.x/erc721

// GET LISTED ON OPENSEA: https://testnets.opensea.io/get-listed/step-two

contract YourCollectible is ERC721, Ownable {

  using Strings for uint256;
  using HexStrings for uint160;
  using ToColor for bytes3;
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  constructor() public ERC721("Loogies", "LOOG") {
    // RELEASE THE LOOGIES!
  }

  mapping (uint256 => bytes3) public color;
  mapping (uint256 => uint256) public chubbiness;
  mapping (uint256 => uint256) public messages;
  mapping (uint256 =>uint256) public progress;

  uint256 mintDeadline = block.timestamp + 24 hours;

  function mintItem()
      public
      returns (uint256)
  {
      require( block.timestamp < mintDeadline, "DONE MINTING");
      _tokenIds.increment();

      uint256 id = _tokenIds.current();
      _mint(msg.sender, id);

      bytes32 predictableRandom = keccak256(abi.encodePacked( blockhash(block.number-1), msg.sender, address(this), id ));
      color[id] = bytes2(predictableRandom[0]) | ( bytes2(predictableRandom[1]) >> 8 ) | ( bytes3(predictableRandom[2]) >> 16 );
      chubbiness[id] = 35+((55*uint256(uint8(predictableRandom[3])))/255);
      messages[id] = 0;
      progress[id] = 6;

      return id;
  }

  function setProgress(uint256 id, uint256 enput) public returns (uint256) {
    progress[id]=enput;
    return progress[id];
  }

  function tokenURI(uint256 id) public view override returns (string memory) {
      require(_exists(id), "not exist");
      string memory name = string(abi.encodePacked('Loogie #',id.toString()));
      string memory description = string(abi.encodePacked('This Loogie is the color #',color[id].toColor(),' with a chubbiness of ',uint2str(chubbiness[id]),'!!!'));
      string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

      return
          string(
              abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                          abi.encodePacked(
                              '{"name":"',
                              name,
                              '", "description":"',
                              description,
                              '", "external_url":"https://burnyboys.com/token/',
                              id.toString(),
                              '", "attributes": [{"trait_type": "color", "value": "#',
                              color[id].toColor(),
                              '"},{"trait_type": "chubbiness", "value": ',
                              uint2str(chubbiness[id]),
                              '}], "owner":"',
                              (uint160(ownerOf(id))).toHexString(20),
                              '", "image": "',
                              'data:image/svg+xml;base64,',
                              image,
                              '"}'
                          )
                        )
                    )
              )
          );
  }

  function generateSVGofTokenById(uint256 id) internal view returns (string memory) {

    string memory svg = string(abi.encodePacked(
      '<svg width="100%" height="100%" viewBox="0 0 900 900" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
        renderTokenById(id),
      '</svg>'
    ));

    return svg;
  }

  // Visibility is `public` to enable it being called by other contracts for composition.
  function renderTokenById(uint256 id) public view returns (string memory) {
    if (ownerOf(id).balance > 5 * 10**18) {
    string memory render = string(abi.encodePacked(
        '<g id="head">',
          '<path id="Bottom" d="M576.90625,539l0,-163" style="fill:#000000;stroke:#000000;stroke-width:5px;"/>',
          '<path id="Bottom1" d="M576.90625,376l-61.3265,-79.92225" style="fill:#000000;stroke:#',color[id].toColor(),';stroke-width:5px;"/>',  
          '<use xlink:href="#Bottom1" transform="scale (-1, 1)" transform-origin="576.90625 576.90625"/>'        
          '<path id="Bottom2" d="M515.57975,296.07775l-60.13928,-16.11427" style="fill:#000000;stroke:#',color[id].toColor(),';stroke-width:5px;"/>',
          '<use xlink:href="#Bottom2" transform="scale (-1, 1)" transform-origin="576.90625 576.90625"/>'
          '<path id="Bottom3" d="M455.44047,279.96348l-35.5503,14.72542" style="fill:#000000;stroke:#',color[id].toColor(),';stroke-width:5px;"/>',
          '<use xlink:href="#Bottom3" transform="scale (-1, 1)" transform-origin="576.90625 576.90625"/>'
          '<path id="Bottom4" d="M455.44047,279.96348l-23.42475,-30.52773" style="fill:#000000;stroke:#',color[id].toColor(),';stroke-width:5px;"/>',
          '<use xlink:href="#Bottom4" transform="scale (-1, 1)" transform-origin="576.90625 576.90625"/>'
          '<path id="Bottom5" d="M515.57975,296.07775l0,-62.26077" style="fill:#000000;stroke:#',color[id].toColor(),';stroke-width:5px;"/>',
          '<use xlink:href="#Bottom5" transform="scale (-1, 1)" transform-origin="576.90625 576.90625"/>'
          '<path id="Bottom6" d="M515.57975,233.81699l-23.42475,-30.52773" style="fill:#000000;stroke:#',color[id].toColor(),';stroke-width:5px;"/>',
          '<use xlink:href="#Bottom6" transform="scale (-1, 1)" transform-origin="576.90625 576.90625"/>'
          '<path id="Bottom7" d="M515.57975,233.81699l23.42475,-30.52773" style="fill:#000000;stroke:#',color[id].toColor(),';stroke-width:5px;"/>',
          '<use xlink:href="#Bottom7" transform="scale (-1, 1)" transform-origin="576.90625 576.90625"/>'
        '</g>'
        
      ));

    return render; }

    else if (ownerOf(id).balance < 5 * 10**18) {

      string memory render = string(abi.encodePacked(
        '<g id="head">',
          '<path id="Bottom" d="M576.90625,539l0,-163" style="fill:#000000;stroke:#',color[id].toColor(),';stroke-width:5px;"/>',
          '<path id="Bottom1" d="M576.90625,376l-61.3265,-79.92225" style="fill:#000000;stroke:#',color[id].toColor(),';stroke-width:5px;"/>',  
          '<use xlink:href="#Bottom1" transform="scale (-1, 1)" transform-origin="576.90625 576.90625"/>'        
          '<path id="Bottom2" d="M515.57975,296.07775l-60.13928,-16.11427" style="fill:#000000;stroke:#',color[id].toColor(),';stroke-width:5px;"/>',
          '<use xlink:href="#Bottom2" transform="scale (-1, 1)" transform-origin="576.90625 576.90625"/>'
          '</g>'
        
      ));
      return render;

    }
  }

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
      if (_i == 0) {
          return "0";
      }
      uint j = _i;
      uint len;
      while (j != 0) {
          len++;
          j /= 10;
      }
      bytes memory bstr = new bytes(len);
      uint k = len;
      while (_i != 0) {
          k = k-1;
          uint8 temp = (48 + uint8(_i - _i / 10 * 10));
          bytes1 b1 = bytes1(temp);
          bstr[k] = b1;
          _i /= 10;
      }
      return string(bstr);
  }
}
