import React from "react";

class Transactions extends React.Component {
  render() {
    return (
      <div >
        <form>
            <fieldset>
                <label >TxHash</label>
                <input name="txHash" type="text" placeholder="Enter tx Hash" id="nameField" />
                <label>Select API service </label>
                <select id="apiService">
                    <option>Select a service</option>
                    <option value="scrape">Scrape</option>
                    <option value="api">EtherScan API</option>
                </select>
                <div>
                    <input className="button-primary" type="submit" value="Send" />
                </div>
                    
            </fieldset>
        </form>
      </div>
    );
  }
}
export default Transactions;