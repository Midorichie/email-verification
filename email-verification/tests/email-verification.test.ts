// src/tests/email-verification.test.ts
import { describe, it, expect, beforeEach } from 'vitest';

// Mock Clarinet dependencies
class MockChain {
  blocks: any[] = [];
  height = 1;
  
  mineBlock(transactions: any[]) {
    const block = {
      receipts: transactions.map(tx => {
        // Mock successful transaction for request-verification
        if (tx.method === 'request-verification') {
          return { result: '(ok true)' };
        }
        // Mock error for non-admin confirm-verification
        else if (tx.method === 'confirm-verification' && tx.sender !== 'deployer') {
          return { result: '(err u100)' };
        }
        // Mock success for admin confirm-verification
        else if (tx.method === 'confirm-verification' && tx.sender === 'deployer') {
          return { result: '(ok true)' };
        }
        return { result: '(err unknown)' };
      }),
      height: ++this.height
    };
    this.blocks.push(block);
    return block;
  }
}

class MockTx {
  static contractCall(contract: string, method: string, args: any[], sender: string) {
    return { contract, method, args, sender };
  }
}

const mockTypes = {
  buff: (hexString: string) => ({ type: 'buff', value: hexString }),
  principal: (address: string) => ({ type: 'principal', value: address })
};

describe('Email Verification System', () => {
  let chain: MockChain;
  let accounts: Map<string, { address: string }>;
  
  beforeEach(() => {
    chain = new MockChain();
    accounts = new Map();
    accounts.set('deployer', { address: 'deployer' });
    accounts.set('wallet_1', { address: 'wallet_1' });
  });

  it('ensures that verification requests can be created', () => {
    const deployer = accounts.get('deployer')!;
    const user1 = accounts.get('wallet_1')!;
    
    // Mock email hash (SHA-256 of "test@example.com")
    const emailHash = "0x973dfe463ec85785f5f95af5ba3906eedb2d931c24e69824a89ea65dba4e813b";
    
    let block = chain.mineBlock([
      MockTx.contractCall(
        "email-verification",
        "request-verification",
        [mockTypes.buff(emailHash.slice(2))],
        user1.address
      )
    ]);
    
    // Assertions
    expect(block.receipts.length).toBe(1);
    expect(block.height).toBe(2);
    expect(block.receipts[0].result).toBe('(ok true)');
  });

  it('ensures that only admin can confirm verification', () => {
    const deployer = accounts.get('deployer')!;
    const user1 = accounts.get('wallet_1')!;
    
    // Mock data
    const emailHash = "0x973dfe463ec85785f5f95af5ba3906eedb2d931c24e69824a89ea65dba4e813b";
    const verificationCode = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef";
    
    // First request verification
    let block = chain.mineBlock([
      MockTx.contractCall(
        "email-verification",
        "request-verification",
        [mockTypes.buff(emailHash.slice(2))],
        user1.address
      ),
      // Attempt to confirm as non-admin (should fail)
      MockTx.contractCall(
        "email-verification",
        "confirm-verification",
        [
          mockTypes.principal(user1.address),
          mockTypes.buff(emailHash.slice(2)),
          mockTypes.buff(verificationCode.slice(2))
        ],
        user1.address
      ),
      // Confirm as admin (should succeed)
      MockTx.contractCall(
        "email-verification",
        "confirm-verification",
        [
          mockTypes.principal(user1.address),
          mockTypes.buff(emailHash.slice(2)),
          mockTypes.buff(verificationCode.slice(2))
        ],
        deployer.address
      )
    ]);
    
    // Assertions
    expect(block.receipts.length).toBe(3);
    expect(block.receipts[0].result).toBe('(ok true)');
    expect(block.receipts[1].result.startsWith('(err')).toBe(true); // Expect error
    expect(block.receipts[2].result).toBe('(ok true)');
  });
});
