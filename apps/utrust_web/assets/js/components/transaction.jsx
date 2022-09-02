import React  from "react";

const Transaction = (props) => {
  const { transaction } = props;
  return (
    <div>
      <ul>
        <li><strong>TxHash: </strong> {transaction.txHash} </li>
        <li className={transaction.status}><strong>Status:</strong> {transaction.status} </li>
        { transaction.from && (<li><strong>From: </strong> {transaction.from}</li>)}
        { transaction.to && (<li><strong>To:</strong> {transaction.to}</li>) }
        { transaction.block && (<li><strong>Block:</strong> {transaction.block} - ({transaction.blockConfirmations})</li>)}
        { transaction.valueEther && (<li><strong>Value:</strong> {transaction.valueEther} - ({transaction.valueUsd})</li>)}
        { transaction.feeEther && (<li><strong>Fee:</strong> {transaction.feeEther} - ({transaction.feeUsd})</li>)}
      </ul>
    </div>
  );
};

export default Transaction;