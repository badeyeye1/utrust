import React, { useState } from 'react';
import { useMutation, gql } from '@apollo/client';
import Transaction from './transaction';

const VERIFY_TX_MUTATION = gql`
  mutation TxMutation(
    $txHash: String!
    $scrape: Boolean
  ) {
    verifyTransaction(txHash: $txHash, scrape: $scrape) {
      txHash
      status
      from
      to
      block
      blockConfirmations
      valueEther
      valueUsd
      feeEther
      feeUsd
    }
  }
`;


const TxForm = () => {
  const [formState, setFormState] = useState({
    txHash: '',
    scrape: true
  });

  const [verifyTransaction, { data, loading, error }] = useMutation(VERIFY_TX_MUTATION, {
    variables: {
      txHash: formState.txHash,
      scrape: formState.scrape
    }
  });
 
  return (
    <div>
      <form
        onSubmit={(e) => {
          e.preventDefault();
          verifyTransaction()
        }}
      >
        <div className="flex flex-column mt3">
          <input
            className="mb2"
            value={formState.txHash}
            onChange={(e) =>
              setFormState({
                ...formState,
                txHash: e.target.value
              })
            }
            type="text"
            placeholder="Enter tx Hash"
          />
        </div>

        <div className="flex flex-column mt3">
            <label>
                <input
                    className="mb2"
                    name='scrape'
                    value={true}
                    checked={formState.scrape === true}
                    onChange={(e) =>
                    setFormState({
                        ...formState,
                        scrape: !formState.scrape 
                    })
                    
                }
                    type="radio"
                />
                Use scrapper
      
                <input
                    className="mb2"
                    name='scrape'
                    checked={formState.scrape === false}
                    value={false}
                    onChange={(e) =>
                    setFormState({
                        ...formState,
                        scrape: !formState.scrape
                    })
                }
                    type="radio"
                />
                Use API
          </label>
        </div>
        <button type="submit"> {loading ? "Verifying ..." : "Verfiy"} </button>
      </form>

      {data && <Transaction transaction={data.verifyTransaction} />}

      {error && (<div>
        <p className='failed'>Trasaction verification failed! Reason: <em>{error.message}</em></p>
      </div>)}

    </div>
  );
};

export default TxForm;