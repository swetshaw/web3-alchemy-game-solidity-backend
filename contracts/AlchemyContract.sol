//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./libraries/Base64.sol";

contract AlchemyContract is ERC721URIStorage {
    struct CharacterAttributes {
        uint256 characterIndex;
        string characterURI;
    }

    // The tokenId is the NFTs unique identifier, it's just a number that goes
    // 0, 1, 2, 3, etc.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    CharacterAttributes[] defaultCharacters;
    CharacterAttributes[] tempCharacters;

    // We create a mapping from the nft's tokenId => that NFTs attributes.
    mapping(uint256 => CharacterAttributes) public nftTokenIdToAttributes;
    event CharacterNFTMinted(
        address sender,
        uint256 tokenId,
        uint256 characterIndex
    );

    mapping(address => uint256[]) public nftHolders;

    constructor(string[] memory characterURIs) ERC721("Alchemists", "AL") {
        for (uint256 i = 0; i < characterURIs.length; i += 1) {
            defaultCharacters.push(
                CharacterAttributes({
                    characterIndex: i,
                    characterURI: characterURIs[i]
                })
            );
            // Hardhat's use of console.log() allows up to 4 parameters in any order of following types: uint, string, bool, address
            console.log("Done initializing character %s", i);
        }

        _tokenIds.increment();
    }

    function getDefaultCharacters()
        public
        view
        returns (CharacterAttributes[] memory)
    {
        return defaultCharacters;
    }

    function mintNFT(uint256 _characterId) public {
        uint256 newTokenId = _tokenIds.current();

        _safeMint(msg.sender, newTokenId);

        nftTokenIdToAttributes[newTokenId] = CharacterAttributes({
            characterIndex: _characterId,
            characterURI: defaultCharacters[_characterId].characterURI
        });

        string memory chartokenURI = defaultCharacters[_characterId]
            .characterURI;
        _setTokenURI(newTokenId, chartokenURI);
        console.log(
            "Minted NFT w/ tokenId %s and characterIndex %s",
            newTokenId,
            _characterId
        );

        // Keep an easy way to see who owns what NFT.
        nftHolders[msg.sender].push(newTokenId);

        // Increment the tokenId for the next person that uses it.
        _tokenIds.increment();
        emit CharacterNFTMinted(msg.sender, newTokenId, _characterId);
    }

    function isOwner(uint256 _tokenId) public view returns (bool) {
        // bool owner = false;
        for (uint256 i; i < nftHolders[msg.sender].length; i++) {
            if (nftHolders[msg.sender][i] == _tokenId) {
                return true;
            }
        }
        return false;
    }

    function combineNFTs(uint256 _tokenId1, uint256 _tokenId2) public {
        if (isOwner(_tokenId1) && isOwner(_tokenId2)) {
            console.log("%s is the owner of the NFTs", msg.sender);
            if (_tokenId1 == 1 && _tokenId2 == 2) {
                transferFrom(msg.sender, address(this), _tokenId1);
                transferFrom(msg.sender, address(this), _tokenId2);
                mintNFT(2);
            }
        }
    }

    // function getUserNFTS() public returns(CharacterAttributes[] memory) {
    //     if (nftHolders[msg.sender].length != 0) {
    //         CharacterAttributes[] memory attributes;
    //         tempCharacters = attributes;
    //         for (uint256 i; i < nftHolders[msg.sender].length; i++) {
    //             tempCharacters.push(
    //                 nftTokenIdToAttributes[nftHolders[msg.sender][i]]
    //             );
    //         }
    //         return tempCharacters;
    //     }
    // }

    // function tokenURI(uint256 _tokenId)
    //     public
    //     view
    //     override
    //     returns (string memory)
    // {
    //     CharacterAttributes memory charAttributes = nftTokenIdToAttributes[
    //         _tokenId
    //     ];

    //     string memory power = Strings.toString(charAttributes.power);
    //     string memory json = Base64.encode(
    //         bytes(
    //             string(
    //                 abi.encodePacked(
    //                     '{"name": "',
    //                     charAttributes.name,
    //                     " -- NFT #: ",
    //                     Strings.toString(_tokenId),
    //                     '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
    //                     charAttributes.imageURI,
    //                     '", "attributes": [ { "trait_type": "power", "value": ',
    //                     power,
    //                     '}, { "trait_type": "Gene", "value": ',
    //                     charAttributes.geneType,
    //                     "} ]}"
    //                 )
    //             )
    //         )
    //     );

    //     string memory output = string(
    //         abi.encodePacked("data:application/json;base64,", json)
    //     );

    //     return output;
    // }
}
