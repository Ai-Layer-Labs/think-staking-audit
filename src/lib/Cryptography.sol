// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';

contract Cryptography {
  using ECDSA for bytes32;

  /**
   * @notice To verify that data was signed by the signer
   * @param signer The address who (presumably) signed the message
   * @param data message to sign
   * @param signature The signature passed from the caller (signed message)
   * @return bool if the signer is the address who signed the message
   */
  function verifySignature(
    address signer,
    bytes memory data,
    bytes memory signature
  ) public pure returns (bool) {
    address signer_ = extractSigner(data, signature);
    return signer == signer_;
  }

  /**
   * @notice Extracts signer from the signed message
   * @param data message to sign
   * @param signature The signature passed from the caller
   * @return signer The signer address
   */
  function extractSigner(
    bytes memory data,
    bytes memory signature
  ) public pure returns (address) {
    bytes32 ethSignedMessageHash = keccak256(
      abi.encodePacked('\x19Ethereum Signed Message:\n32', keccak256(data))
    );
    (address recovered, ECDSA.RecoverError error, ) = ethSignedMessageHash.tryRecover(signature);
    if (error != ECDSA.RecoverError.NoError) {
      return address(0);
    }
    return recovered;
  }
}
