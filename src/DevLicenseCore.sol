// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {NormalizedPriceProvider} from "./provider/NormalizedPriceProvider.sol";
import {ILicenseAccountFactory} from "./interface/ILicenseAccountFactory.sol";
import {IDevLicenseDimo} from "./interface/IDevLicenseDimo.sol";
import {IDimoCredit} from "./interface/IDimoCredit.sol";
import {IDimoToken} from "./interface/IDimoToken.sol";

/**
 * @title Developer License Core
 * @dev Implements the core functionalities for managing developer licenses within the DIMO ecosystem.
 * @notice This contract manages the creation, administration, and validation of developer licenses, 
 *         integrating with DIMO's token and credit systems.
 */
contract DevLicenseCore is IDevLicenseDimo, AccessControl {

    /*//////////////////////////////////////////////////////////////
                             Access Controls
    //////////////////////////////////////////////////////////////*/
    
    bytes32 public constant LICENSE_ADMIN_ROLE = keccak256("LICENSE_ADMIN_ROLE");

    /*//////////////////////////////////////////////////////////////
                              Member Variables
    //////////////////////////////////////////////////////////////*/
    
    IDimoToken public _dimoToken; 
    IDimoCredit public _dimoCredit;
    NormalizedPriceProvider public _provider;
    ILicenseAccountFactory public _licenseAccountFactory;
    
    /// @notice The period after which a signer is considered expired.
    uint256 public _periodValidity; 
    /// @notice Cost of a single license in USD with 18 decimals.
    uint256 public _licenseCostInUsd1e18;
    /// @notice Counter to keep track of the issued licenses.
    uint256 public _counter;
    /// @notice Address that receives proceeds from the sale of licenses.
    address public _receiver;

    /*//////////////////////////////////////////////////////////////
                              Mappings
    //////////////////////////////////////////////////////////////*/
    
    mapping(uint256 => address) public _ownerOf;
    mapping(uint256 => address) public _tokenIdToClientId;
    mapping(address => uint256) public _clientIdToTokenId;
    /// @notice Mapping from license ID to signer addresses with their expiration timestamps.
    mapping(uint256 => mapping(address => uint256)) public _signers; 

    /*//////////////////////////////////////////////////////////////
                            Events
    //////////////////////////////////////////////////////////////*/
    
    ///@dev on mint & burn
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId); 
    event SignerEnabled(uint256 indexed tokenId, address indexed signer);
    event Locked(uint256 indexed tokenId);

    event UpdateLicenseCost(uint256 licenseCost);
    event UpdateReceiverAddress(address receiver_);
    event UpdateDimoTokenAddress(address dimoToken_);
    event UpdatePeriodValidity(uint256 periodValidity);
    event UpdatePriceProviderAddress(address provider);
    event UpdateDimoCreditAddress(address dimoCredit_);
    event UpdateLicenseAccountFactoryAddress(address licenseAccountFactory_);

    /*//////////////////////////////////////////////////////////////
                            Error Messages
    //////////////////////////////////////////////////////////////*/
    
    string INVALID_TOKEN_ID = "DevLicenseDimo: invalid tokenId";
    string INVALID_OPERATION = "DevLicenseDimo: invalid operation";
    string INVALID_MSG_SENDER = "DevLicenseDimo: invalid msg.sender";

    /*//////////////////////////////////////////////////////////////
                            Modifiers
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Ensures the caller is the owner of the specified token ID.
     */
    modifier onlyTokenOwner(uint256 tokenId) { 
        require(msg.sender == ownerOf(tokenId), INVALID_MSG_SENDER);
        _;
    }

    /**
     * @notice Initializes a new instance of the DevLicenseCore contract.
     * @dev Sets up the contract with the necessary addresses and parameters for operation, 
     *      including setting up roles, linking to $DIMO token and credit contracts, and initializing 
     *      license cost and validity period.
     * @param receiver_ The address where proceeds from the sale of licenses are sent.
     * @param licenseAccountFactory_ The address of the contract responsible for creating new license accounts.
     * @param provider_ Supplies current $DIMO token price to calculate license cost in USD.
     * @param dimoTokenAddress_ The address of the $DIMO token contract.
     * @param dimoCreditAddress_ The address of the DIMO credit contract, an alternative payment method for licenses.
     * @param licenseCostInUsd1e18_ The cost of a single license expressed in USD with 18 decimal places.
     */
    constructor(
        address receiver_,
        address licenseAccountFactory_,
        address provider_,
        address dimoTokenAddress_, 
        address dimoCreditAddress_,
        uint256 licenseCostInUsd1e18_) {

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        
        _periodValidity = 365 days;

        _receiver = receiver_;

        _dimoCredit = IDimoCredit(dimoCreditAddress_);
        _provider = NormalizedPriceProvider(provider_);
    
        _licenseAccountFactory = ILicenseAccountFactory(licenseAccountFactory_);
        _dimoToken = IDimoToken(dimoTokenAddress_);
        _licenseCostInUsd1e18 = licenseCostInUsd1e18_;

        emit UpdatePeriodValidity(_periodValidity);
        emit UpdateLicenseCost(_licenseCostInUsd1e18);
    }

    /*//////////////////////////////////////////////////////////////
                       Signer a.k.a. API Key
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Enables a signer for a specific token ID, granting the signer permission to access 
     *         API functionalities/resources. Only the owner of the token ID can enable a signer.
     *         License can be minted by any EOA and assigned an owner, or by the owner directly. 
     *         the owner then enables a key and/or set of keys to act as a signer, to sign challenges 
     *         from the backend to access API resources.
     * @dev Emits a `SignerEnabled` event upon successfully adding a signer. This function checks 
     *      if the caller owns the token ID and then delegates to `_enableSigner` to update the 
     *      mapping of signers.
     * @param tokenId The unique identifier for the license token.
     * @param signer The address to be enabled as a signer for the specified token ID.
     */
    function enableSigner(uint256 tokenId, address signer) onlyTokenOwner(tokenId) external {
        _enableSigner(tokenId, signer);
    }

    /**
     * @notice Internally enables a signer for a specific token ID by recording the current block 
     *         timestamp as the time of enabling. This function should only be called through `enableSigner`.
     * @dev Updates the `_signers` mapping to mark the `signer` address as enabled for the `tokenId`. 
     *      It records the current block timestamp for the signer.
     * @param tokenId The unique identifier for the license token.
     * @param signer The address to be enabled as a signer for the specified token ID.
     */
    function _enableSigner(uint256 tokenId, address signer) internal {
        _signers[tokenId][signer] = block.timestamp;
        emit SignerEnabled(tokenId, signer);
    }

    /**
     * @notice Checks whether a given address is currently an enabled signer for a specified token ID. 
     *         The signer's enabled status is valid only for the period defined by `_periodValidity`.
     * @dev This function calculates the difference between the current block timestamp and the timestamp 
     *      when the signer was enabled. If the difference exceeds `_periodValidity`, the signer is 
     *      considered no longer enabled.
     * @param tokenId The unique identifier for the license token.
     * @param signer The address to check for being an enabled signer for the specified token ID.
     * @return bool Returns true if the `signer` is currently enabled for the `tokenId` and the period of 
     *         validity has not expired; otherwise, returns false.
     */
    function isSigner(uint256 tokenId, address signer) public view returns (bool) {
        uint256 timestampInit = _signers[tokenId][signer];
        uint256 timestampCurrent = block.timestamp;
        if(timestampCurrent - timestampInit > _periodValidity) {
            return false;
        } else {
            return true;
        }
    }

    /*//////////////////////////////////////////////////////////////
                            Admin Functions
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Sets the receiver address to which the payments will be directed.
     * @dev Can only be called by an account with the `LICENSE_ADMIN_ROLE`. Emits `UpdateReceiverAddress` event.
     * @param receiver_ The new receiver address.
     */
    function setReceiverAddress(address receiver_) external onlyRole(LICENSE_ADMIN_ROLE) {
        _receiver = receiver_;
        emit UpdateReceiverAddress(_receiver);
    }

    /**
     * @notice Sets the cost of obtaining a license in USD (with 18 decimals).
     * @dev Can only be called by an account with the `LICENSE_ADMIN_ROLE`. Emits `UpdateLicenseCost` event.
     * @param licenseCostInUsd1e18_ The new license cost in USD (1e18 = 1 USD).
     */
    function setLicenseCost(uint256 licenseCostInUsd1e18_) external onlyRole(LICENSE_ADMIN_ROLE) {
        _licenseCostInUsd1e18 = licenseCostInUsd1e18_;
        emit UpdateLicenseCost(_licenseCostInUsd1e18);
    }

    /**
     * @notice Sets the validity period for the license.
     * @dev Can only be called by an account with the `LICENSE_ADMIN_ROLE`. Emits `UpdatePeriodValidity` event.
     * @param periodValidity_ The new validity period for the license in seconds.
     */
    function setPeriodValidity(uint256 periodValidity_) external onlyRole(LICENSE_ADMIN_ROLE) {
        _periodValidity = periodValidity_;
        emit UpdatePeriodValidity(_periodValidity);
    }

    /**
     * @notice Sets the address of the price provider contract.
     * @dev Can only be called by an account with the `LICENSE_ADMIN_ROLE`. Emits `UpdatePriceProviderAddress` event.
     * @param providerAddress_ The address of the new price provider contract.
     */
    function setPriceProviderAddress(address providerAddress_) external onlyRole(LICENSE_ADMIN_ROLE) {
        _provider = NormalizedPriceProvider(providerAddress_);
        emit UpdatePriceProviderAddress(providerAddress_);
    }

    /**
     * @notice Sets the address of the DIMO Credit contract.
     * @dev Can only be called by an account with the `LICENSE_ADMIN_ROLE`. Emits `UpdateDimoCreditAddress` event.
     * @param dimoCreditAddress_ The address of the DIMO Credit contract.
     */
    function setDimoCreditAddress(address dimoCreditAddress_) external onlyRole(LICENSE_ADMIN_ROLE) {
        _dimoCredit = IDimoCredit(dimoCreditAddress_);
        emit UpdateDimoCreditAddress(dimoCreditAddress_);
    }

    /**
     * @notice Sets the address of the DIMO Token contract.
     * @dev Can only be called by an account with the `LICENSE_ADMIN_ROLE`. Emits `UpdateDimoTokenAddress` event.
     * @param dimoTokenAddress_ The address of the DIMO Token contract.
     */
    function setDimoTokenAddress(address dimoTokenAddress_) external onlyRole(LICENSE_ADMIN_ROLE) {
        _dimoToken = IDimoToken(dimoTokenAddress_);
        emit UpdateDimoTokenAddress(dimoTokenAddress_);
    }
    
    /**
     * @notice Sets the address of the License Account Factory contract.
     * @dev Can only be called by an account with the `LICENSE_ADMIN_ROLE`. Emits `UpdateLicenseAccountFactoryAddress` event.
     * @param licenseAccountFactory_ The address of the License Account Factory contract.
     */
    function setLicenseFactoryAddress(address licenseAccountFactory_) external onlyRole(LICENSE_ADMIN_ROLE) {
        _licenseAccountFactory = ILicenseAccountFactory(licenseAccountFactory_);
        emit UpdateLicenseAccountFactoryAddress(licenseAccountFactory_);
    }

    /*//////////////////////////////////////////////////////////////
                             NO-OP NFT Logic
    //////////////////////////////////////////////////////////////*/

    /// @notice Prevents approval of token spending by third parties.
    /// @dev This contract does not support approvals, attempting to do so will cause a revert.
    function approve(address /*spender*/, uint256 /*id*/) public virtual {
        revert(INVALID_OPERATION);
    }

    /// @notice Prevents setting approval for all tokens owned by the caller.
    /// @dev This contract does not support setting approval for all, attempting to do so will cause a revert.
    function setApprovalForAll(address /*operator*/, bool /*approved*/) public virtual {
        revert(INVALID_OPERATION);
    }

    /// @notice Prevents transferring tokens from one address to another.
    /// @dev This contract does not support transferring tokens, attempting to do so will cause a revert.
    function transferFrom(address /*from*/, address /*to*/, uint256 /*id*/) public virtual {
        revert(INVALID_OPERATION);
    }

    /// @notice Prevents safe transferring of tokens from one address to another without data.
    /// @dev This contract does not support safe transferring of tokens without data, attempting to do so will cause a revert.
    function safeTransferFrom(
        address /*from*/,
        address /*to*/,
        uint256 /*id*/
    ) public virtual {
        revert(INVALID_OPERATION);
    }

    /// @notice Prevents safe transferring of tokens from one address to another with data.
    /// @dev This contract does not support safe transferring of tokens with data, attempting to do so will cause a revert.
    function safeTransferFrom(
        address /*from*/,
        address /*to*/,
        uint256 /*id*/,
        bytes memory /*data*/
    ) public virtual {
        revert(INVALID_OPERATION);
    }

    /*//////////////////////////////////////////////////////////////
                              NFT Logic
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Returns the total number of tokens in existence.
     * @return totalSupply_ The total supply of tokens.
     */
    function totalSupply() external view returns (uint256 totalSupply_) {
        totalSupply_ = _counter;
    } 

    /**
     * @dev Returns the address of the owner of a given tokenId.
     * @param tokenId The identifier for a token.
     * @return owner The address of the owner of the specified token.
     * @notice The token must exist (tokenId must have been minted).
     */
    function ownerOf(uint256 tokenId) public view virtual returns (address owner) {
        require((owner = _ownerOf[tokenId]) != address(0), INVALID_TOKEN_ID);
    }

    /*//////////////////////////////////////////////////////////////
                            SBT Logic
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev ERC5192: Minimal Soulbound NFTs Minimal interface for 
     * soulbinding EIP-721 NFTs
     */
    function locked(uint256 tokenId) external view returns (bool locked_) {
        require(locked_ = _exists(tokenId), INVALID_TOKEN_ID);
    }

    /*//////////////////////////////////////////////////////////////
                         Private Helper Functions
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Checks if a token exists by verifying the owner is not the zero address.
     * Tokens are considered to exist if they have been minted and not burned.
     * @param tokenId The identifier for an NFT.
     * @return bool True if the token exists (has an owner other than the zero address), false otherwise.
     */
    function _exists(uint256 tokenId) private view returns (bool) {
        return _ownerOf[tokenId] != address(0);
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev See {IERC165-supportsInterface}.
     * @notice Checks if the contract implements an interface.
     *         Implements ERC165 to support interface detection for ERC721 (NFT), ERC5192 (Lockable NFT), 
     *         and ERC721Metadata.
     * @param interfaceId The interface identifier, as specified in ERC-165.
     * @return bool True if the contract implements `interfaceId` and `interfaceId` is not 0xffffffff, 
     *         false otherwise.
     */
    function supportsInterface(bytes4 interfaceId) public override pure returns (bool) {
        return
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0xb45a3c0e || // ERC165 Interface ID for ERC5192
            interfaceId == 0x5b5e139f;   // ERC165 Interface ID for ERC721Metadata
    }

}
