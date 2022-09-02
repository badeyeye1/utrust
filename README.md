# Utrust Challenge - Fullstack Developer solution

## Approach

In order to solve the challenge, I opted to use a tech stack as close to what is in use at `Utrust` (`React`, `Graphql`, less `Commanded`) although I could have used Liveview.

In verifying transactions using Etherscan API, I found the following issues
-  Etherscan API `Transactions` endpoint (https://docs.etherscan.io/api-endpoints/stats#check-contract-execution-status) does not verify if a `tx_hash`is valid and returns successful response for randomly generated strings
- It returns limited information about the transaction.

In the light of the above, I implemented transaction verification via the Etherscan API and also through scraping the `Etherscan` transactions webpage (https://etherscan.io/tx/0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0 )  and exposed a  `graphql` endpoint that allows a client to specify  a verification channel.

## Demo
Successful transaction
![Successful transaction](https://github.com/badeyeye1/utrust/blob/main/utrust-successful-tx-hash.gif)

Failed transaction
![Failed Transaction](https://github.com/badeyeye1/utrust/blob/main/utrust-failed-tx-hash.gif)
