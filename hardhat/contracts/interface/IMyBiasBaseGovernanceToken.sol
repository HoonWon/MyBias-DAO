pragma experimental ABIEncoderV2;

interface IMyBiasBaseGovernanceToken {
    struct Checkpoint {
        uint32 fromBlock;
        uint224 votes;
    }

    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function MINTER_ROLE() external view returns (bytes32);

    function NFT_CONTRACT() external view returns (bytes32);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    function checkpoints(address account, uint32 pos)
        external
        view
        returns (Checkpoint memory);

    function decimals() external view returns (uint8);

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool);

    function delegate(address delegatee) external;

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function delegates(address account) external view returns (address);

    function getPastTotalSupply(uint256 blockNumber)
        external
        view
        returns (uint256);

    function getPastVotes(address account, uint256 blockNumber)
        external
        view
        returns (uint256);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function getVotes(address account) external view returns (uint256);

    function grantRole(bytes32 role, address account) external;

    function hasRole(bytes32 role, address account)
        external
        view
        returns (bool);

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);

    function init(
        address ownerAddress,
        address nftContract,
        string memory _target
    ) external;

    function isInitialized() external view returns (bool);

    function mint(address to, uint256 amount) external;

    function burnAndMint(address from, address to) external;

    function burnFromNftContract(address to) external;

    function name() external view returns (string memory);

    function nonces(address owner) external view returns (uint256);

    function numCheckpoints(address account) external view returns (uint32);

    function owner() external view returns (address);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function renounceOwnership() external;

    function renounceRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function symbol() external view returns (string memory);

    function target() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transferOwnership(address newOwner) external;
}
