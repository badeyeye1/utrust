# Utrust

 Utrust Challenge - Fullstack Developer solution

## Approach

In order to solve the challenge, I opted to use a tech stack as close to what is in use at `Utrust` (`React`, `Graphql`, less `Commanded`) although I could have used Liveview.

In verifying transactions using Etherscan API, I found the following issues
-  Etherscan API `Transactions` endpoint (https://docs.etherscan.io/api-endpoints/stats#check-contract-execution-status) does not verify if a `tx_hash`is valid and returns successful response for randomly generated strings
- It returns limited information about the transaction.

In the light of the above, I implemented transaction verification via the Etherscan API and also through scraping the `Etherscan` transactions webpage (https://etherscan.io/tx/0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0 )  and exposed a  `graphql` endpoint that allows a client to specify a verification channel.

### Setting Up the Stack

#### Versioned dependencies

Following core dependencies in the Utrust stack are versioned in `.tool-versions`:

- Erlang (OTP)
- Elixir
- NodeJS

In order to install these locally via [asdf](https://asdf-vm.com), just run:

```sh
asdf install
```

#### System libraries

Following system libraries are required:

- Docker-Compose 1.29 (optional)

They need to be installed manually using means matching your specific platform.

#### Data storage

Following data storage dependencies are required:

- PostgreSQL v13

It may be installed manually or started in Docker with:

```sh
docker-compose up -d
```

They may then be stopped with:

```sh
docker-compose down
```

### Running the Server

To start your Phoenix server:

- Install dependencies and setup database for all apps with `mix setup`
- Install Node.js dependencies with `npm` inside the `assets` directory in the `UtrustWeb` app
- Start Phoenix endpoint with `mix phx.server`

```
mix setup
cd apps/utrust_web/assets; npm install; cd -
mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
Below is a list of some test transactions.

- 0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0
- 0x15f8e5ea1079d9a0bb04a4c58ae5fe7654b5b2b4463375ff7ffb490aa0032f3a
- 0x513c1ba0bebf66436b5fed86ab668452b7805593c05073eb2d51d3a52f480a76


## Demo
Successful transaction
![Successful transaction](https://github.com/badeyeye1/utrust/blob/main/utrust-successful-tx-hash.gif)

Failed transaction
![Failed Transaction](https://github.com/badeyeye1/utrust/blob/main/utrust-failed-tx-hash.gif)
