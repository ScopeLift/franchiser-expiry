// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8;

import {IFranchiserExpiryFactoryErrors} from "./IFranchiserExpiryFactoryErrors.sol";
import {IFranchiserImmutableState} from "../IFranchiserImmutableState.sol";
import {Franchiser} from "../../Franchiser.sol";

/// @title Interface for the FranchiserExpiryFactory contract.
interface IFranchiserExpiryFactory is IFranchiserExpiryFactoryErrors, IFranchiserImmutableState {
    /// @notice The initial value for the maximum number of `subDelegatee` addresses that a Franchiser
    ///         contract can have at any one time.
    /// @dev Decreases by half every level of nesting.
    ///      Of type uint96 for storage packing in Franchiser contracts.
    /// @return The intial maximum number of `subDelegatee` addresses.
    function INITIAL_MAXIMUM_SUBDELEGATEES() external returns (uint96);

    /// @notice The implementation contract used to clone Franchiser contracts.
    /// @dev Used as part of an EIP-1167 proxy minimal proxy setup.
    /// @return The Franchiser implementation contract.
    function franchiserImplementation() external view returns (Franchiser);

    /// @notice Returns the expiration timestamp for a factory-owned `Franchiser`.
    /// @param franchiser The target `franchiser`.
    /// @return The timestamp when the franchiser's delegated voting power expires.
    function expirations(Franchiser franchiser) external view returns (uint256);

    /// @notice Looks up the Franchiser associated with the `owner` and `delegatee`.
    /// @dev Returns the address of the Franchiser even it it does not yet exist,
    ///      thanks to CREATE2.
    /// @param owner The target `owner`.
    /// @param delegatee The target `delegatee`.
    /// @return franchiser The Franchiser contract, whether or not it exists yet.
    function getFranchiser(address owner, address delegatee) external view returns (Franchiser franchiser);

    /// @notice Funds the Franchiser contract associated with the `delegatee`
    ///         from the sender of the call.
    /// @dev Requires the sender of the call to have approved this contract for `amount`.
    ///      If a Franchiser does not yet exist, one is created.
    /// @param delegatee The target `delegatee`.
    /// @param amount The amount of `votingToken` to allocate.
    /// @param expiration The desired expiration timestamp of the Franchiser's delegated voting power.
    /// @return franchiser The Franchiser contract.
    function fund(address delegatee, uint256 amount, uint256 expiration) external returns (Franchiser franchiser);

    /// @notice Calls fund many times.
    /// @dev Requires the sender of the call to have approved this contract for sum of `amounts`.
    /// @param delegatees The target `delegatees`.
    /// @param amounts The amounts of `votingToken` to allocate.
    /// @param expiration The desired expiration timestamp of the Franchisers' delegated voting power.
    /// @return franchisers The Franchiser contracts.
    function fundMany(address[] calldata delegatees, uint256[] calldata amounts, uint256 expiration)
        external
        returns (Franchiser[] memory franchisers);

    /// @notice Recalls funds in the Franchiser contract associated with the `delegatee`.
    /// @dev No-op if a Franchiser does not exist.
    /// @param delegatee The target `delegatee`.
    /// @param to The `votingToken` recipient.
    function recall(address delegatee, address to) external;

    /// @notice Calls recall many times.
    /// @param delegatees The target `delegatees`.
    /// @param tos The `votingToken` recipients.
    function recallMany(address[] calldata delegatees, address[] calldata tos) external;

    /// @notice Recalls voting tokens from an expired franchiser back to the owner.
    /// @dev Can be called by anyone, but only after the franchiser's expiration timestamp.
    /// @dev Will revert with `FranchiserNotExpired` if called before expiration time.
    /// @param owner The Franchiser's delegator.
    /// @param delegatee The Franchiser's delegatee, whose voting power is being recalled.
    function recallExpired(address owner, address delegatee) external;

    /// @notice Calls recallExpired many times.
    /// @param owners The Franchisers' owners.
    /// @param delegatees The Franchisers' delegatees, whose voting power is being recalled.
    function recallManyExpired(address[] calldata owners, address[] calldata delegatees) external;

    /// @notice Funds the Franchiser contract associated with the `delegatee`
    ///         using a signature.
    /// @dev The signature must have been produced by the sender of the call.
    ///      If a Franchiser does not yet exist, one is created.
    /// @param delegatee The target `delegatee`.
    /// @param amount The amount of `votingToken` to allocate.
    /// @param expiration The desired expiration timestamp of the Franchiser's delegated voting power.
    /// @param deadline A timestamp which the current timestamp must be less than or equal to.
    /// @param v Must produce valid secp256k1 signature from the holder along with `r` and `s`.
    /// @param r Must produce valid secp256k1 signature from the holder along with `v` and `s`.
    /// @param s Must produce valid secp256k1 signature from the holder along with `v` and `r`.
    /// @return franchiser The Franchiser contract.
    function permitAndFund(
        address delegatee,
        uint256 amount,
        uint256 expiration,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (Franchiser franchiser);

    /// @notice Calls permitAndFund many times.
    /// @dev The permit must be for the sum of `amounts`.
    /// @param delegatees The target `delegatees`.
    /// @param amounts The amounts of `votingToken` to allocate.
    /// @param expiration The desired expiration timestamp of the Franchiser's delegated voting power.
    /// @param deadline A timestamp which the current timestamp must be less than or equal to.
    /// @param v Must produce valid secp256k1 signature from the holder along with `r` and `s`.
    /// @param r Must produce valid secp256k1 signature from the holder along with `v` and `s`.
    /// @param s Must produce valid secp256k1 signature from the holder along with `v` and `r`.
    /// @return franchisers The Franchiser contracts.
    function permitAndFundMany(
        address[] calldata delegatees,
        uint256[] calldata amounts,
        uint256 expiration,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (Franchiser[] memory franchisers);
}
