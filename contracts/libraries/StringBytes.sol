// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Library string parse to bytes
 * @author Kiwari Labs
 */

library StringBytes {
    function parseHexStringToBytes(string memory input) internal pure returns (bytes memory result) {
        assembly {
            let str := add(input, 0x20) // skip length field of string
            let strLen := mload(input)

            // Require length >= 2
            if lt(strLen, 2) {
                mstore(0x00, 0x4d757374207374617274207769746820307800000000000000000000000000) // "Must start with 0x"
                revert(0x00, 0x20)
            }

            // Check prefix '0' and 'x' or 'X'
            let c0 := byte(0, mload(str))
            let c1 := byte(0, mload(add(str, 1)))
            if or(iszero(eq(c0, 0x30)), iszero(or(eq(c1, 0x78), eq(c1, 0x58)))) {
                mstore(0x00, 0x4d757374207374617274207769746820307800000000000000000000000000) // "Must start with 0x"
                revert(0x00, 0x20)
            }

            let hexLen := sub(strLen, 2)

            // Check even length after "0x"
            if mod(hexLen, 2) {
                mstore(0x00, 0x486578206c656e677468206d757374206265206576656e000000000000000000) // "Hex length must be even"
                revert(0x00, 0x20)
            }

            // Allocate result bytes array, length = hexLen / 2
            let resultLen := div(hexLen, 2)
            result := mload(0x40)
            mstore(result, resultLen)
            let dest := add(result, 0x20)

            // Start decoding loop
            // src pointer to first hex char (skip 2 bytes prefix)
            let src := add(str, 2)
            let end := add(src, hexLen)

            for {} lt(src, end) {} {
                // Load two chars, convert each to nibble and combine
                let hi := fromHexChar(byte(0, mload(src)))
                let lo := fromHexChar(byte(0, mload(add(src, 1))))

                mstore8(dest, or(shl(4, hi), lo))

                src := add(src, 2)
                dest := add(dest, 1)
            }

            // Update free memory pointer
            mstore(0x40, add(dest, 0))

            // Internal assembly function to convert hex char to nibble
            function fromHexChar(c) -> nibble {
                switch c
                case 0x30 /*'0'*/ {
                    nibble := 0
                }
                case 0x31 /*'1'*/ {
                    nibble := 1
                }
                case 0x32 /*'2'*/ {
                    nibble := 2
                }
                case 0x33 /*'3'*/ {
                    nibble := 3
                }
                case 0x34 /*'4'*/ {
                    nibble := 4
                }
                case 0x35 /*'5'*/ {
                    nibble := 5
                }
                case 0x36 /*'6'*/ {
                    nibble := 6
                }
                case 0x37 /*'7'*/ {
                    nibble := 7
                }
                case 0x38 /*'8'*/ {
                    nibble := 8
                }
                case 0x39 /*'9'*/ {
                    nibble := 9
                }
                case 0x61 /*'a'*/ {
                    nibble := 10
                }
                case 0x62 /*'b'*/ {
                    nibble := 11
                }
                case 0x63 /*'c'*/ {
                    nibble := 12
                }
                case 0x64 /*'d'*/ {
                    nibble := 13
                }
                case 0x65 /*'e'*/ {
                    nibble := 14
                }
                case 0x66 /*'f'*/ {
                    nibble := 15
                }
                default {
                    revert(0, 0)
                }
            }
        }
    }
}
